import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:git_geek/core/config/app_config.dart';

import 'package:crypto/crypto.dart';
import 'package:git_geek/core/git/git_messages.dart';
import 'package:git_geek/core/git/git_runner_base.dart';
import 'package:git_geek/core/git/git_url.dart';
import 'package:path_provider/path_provider.dart';

/// 文案由调用方按语言备好后传入 [GitMessages]，无全局语言状态（调用方见 Repository）。

/// 同一 URL 的串行锁
class _AsyncLock {
  // 链式尾巴：后任务排在前任务完成后执行，实现同 URL 串行。
  Future<void> _tail = Future.value();
  Future<T> run<T>(Future<T> Function() fn) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await fn());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }
}

/// 远程仓库解析器（实例类，构造注入 [GitRunner]）。
/// 移动/桌面端：URL 自动克隆到缓存并增量更新；Web 等无 git 平台：抛友好错误。
/// 经 `lib/core/git/git_providers.dart` 装配；同 URL 串行锁为实例级（单例下等价进程级）。
/// 纯路径推导 [repoNameFromUrl]/[cacheDirHintFor] 保持静态，无 IO 依赖。
class RemoteRepoResolver {
  final GitRunner _runner;
  RemoteRepoResolver(this._runner);

  final Map<String, _AsyncLock> _locks = {};
  _AsyncLock _lockFor(String url) => _locks.putIfAbsent(url, () => _AsyncLock());

  static Future<Directory> _cacheRoot() async {
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      final base = (appData != null && appData.trim().isNotEmpty)
          ? Directory('${appData.trim()}\\${AppConfig.cacheDirName}')
          : Directory(
              '${Platform.environment['USERPROFILE'] ?? '.'}\\'
              '.${AppConfig.cacheDirName}');
      final dir = Directory('${base.path}\\${AppConfig.cacheSubDirName}');
      await dir.create(recursive: true);
      return dir;
    }
    try {
      final support = await getApplicationSupportDirectory();
      final dir = Directory(
        '${support.path}/${AppConfig.cacheDirName}/${AppConfig.cacheSubDirName}',
      );
      await dir.create(recursive: true);
      return dir;
    } catch (_) {
      final home = Platform.environment['HOME'] ?? '.';
      final dir = Directory(
        '$home/.${AppConfig.cacheDirName}/${AppConfig.cacheSubDirName}',
      );
      await dir.create(recursive: true);
      return dir;
    }
  }

  /// 从 URL 推断仓库名：兼容 scp 与 http 形式并去 `.git` 后缀。
  static String repoNameFromUrl(String url) {
    // 去尾斜杠，避免 last 为空。
    var t = url.trim().replaceAll(RegExp(r'/+$'), '');
    if (GitUrlDetector.isRemoteUrl(t) && !t.contains('://') && t.contains(':')) {
      t = t.substring(t.indexOf(':') + 1);
    } else if (t.contains('://')) {
      t = t.substring(t.indexOf('://') + 3);
    }
    final last = t.split('/').last;
    final name = last.endsWith('.git')
        ? last.substring(0, last.length - 4)
        : last;
    return name.isEmpty ? 'repo' : name;
  }

  /// 按 URL 计算本地缓存目录：名 + sha1 前 10 位，防重名冲突。
  static Future<Directory> cacheDirFor(String url) async {
    final root = await _cacheRoot();
    // 非文件名字符统一替换为下划线。
    final name =
        repoNameFromUrl(url).replaceAll(RegExp(r'[^\w.\-]'), '_');
    // sha1 取前 10 位作短哈希，区分同名不同 URL。
    final short = sha1.convert(utf8.encode(url.trim())).toString().substring(0, 10);
    return Directory('${root.path}/$name-$short');
  }

  /// 仅展示用：同步拼出缓存路径（不触发 IO 检测）。
  /// 纯路径推导，无 runner 依赖，保持静态。
  static Future<String> cacheDirHintFor(String url) async {
    if (!GitUrlDetector.isRemoteUrl(url)) return '';
    try {
      return (await cacheDirFor(url)).path;
    } catch (_) {
      return '';
    }
  }

  /// 是否为可用仓库目录：`rev-parse --git-dir` 成功即视为可用。
  Future<bool> isUsableRepoDir(Directory dir) async {
    if (!await dir.exists()) return false;
    final r = await _runner.run(dir.path, ['rev-parse', '--git-dir']);
    return r.ok;
  }

  Future<void> _deleteDirRobust(Directory dir, GitMessages messages) async {
    if (!await dir.exists()) return;
    try {
      await for (final e in dir.list(recursive: true, followLinks: false)) {
        try {
          if (e is File) {
            await e.setLastModified(await e.lastModified());
          }
        } catch (_) {}
      }
    } catch (_) {}
    try {
      if (Platform.isWindows) {
        // 去掉只读属性，防止删不掉
        await Process.run('attrib', ['-R', '/S', '/D', '${dir.path}\\*']);
      }
    } catch (_) {}
    await dir.delete(recursive: true);
    if (await dir.exists()) {
      final rest = await dir.list().toList().catchError((_) => <FileSystemEntity>[]);
      if (rest.isNotEmpty) {
        throw Exception('${messages.cacheCleanFail}: ${dir.path}');
      }
    }
  }

  Future<void> _cloneSmart(
    Directory target,
    String url,
    GitMessages messages,
    void Function(String)? onProgress,
  ) async {
    var r = await _runner.run(null, [
      'clone',
      '--filter=blob:none',
      '--progress',
      url,
      target.path,
    ], onProgress: onProgress);
    if (r.ok) return;
    await _deleteDirRobust(target, messages);
    // 部分托管不支持 filter，失败回退普通 clone。
    onProgress?.call(messages.filterFallback);
    r = await _runner.run(null, [
      'clone',
      '--progress',
      url,
      target.path,
    ], onProgress: onProgress);
    if (!r.ok) throw Exception(r.stderr);
  }

  Future<void> _fetch(Directory repoDir, String url) async {
    var r = await _runner.run(
        repoDir.path, ['remote', 'set-url', 'origin', url]);
    if (!r.ok) throw Exception(r.stderr);
    r = await _runner.run(
        repoDir.path, ['fetch', '--tags', '--prune', 'origin']);
    if (!r.ok) throw Exception(r.stderr);
    await _runner.run(repoDir.path, ['merge', '--ff-only', 'FETCH_HEAD']);
  }

  /// 解析仓库路径：本地目录直接返回，远程 URL 走缓存克隆/增量更新。
  Future<Directory> resolve(
    String repoPath,
    GitMessages messages, {
    bool fetchIfCached = true,
    void Function(String)? onProgress,
  }) async {
    final trimmed = repoPath.trim();
    if (trimmed.isEmpty) return Directory.current;
    if (!GitUrlDetector.isRemoteUrl(trimmed)) {
      final f = Directory(trimmed);
      if (!await f.exists()) {
        throw Exception('${messages.dirNotExist}: $trimmed');
      }
      return f;
    }
    if (!_runner.supportsNativeGit) {
      throw Exception(messages.platformUnsupported);
    }
    final target = await cacheDirFor(trimmed);
    return _lockFor(trimmed).run(() async {
      if (await isUsableRepoDir(target)) {
        if (fetchIfCached) {
          onProgress?.call(messages.updatingCache);
          try {
            await _fetch(target, trimmed);
          } catch (e) {
            onProgress?.call('${messages.updateStaleCache}: $e');
          }
        }
        return target;
      }
      await _deleteDirRobust(target, messages);
      onProgress?.call(messages.cloningCache);
      try {
        await _cloneSmart(target, trimmed, messages, onProgress);
      } catch (e) {
        try {
          await _deleteDirRobust(target, messages);
        } catch (_) {}
        rethrow;
      }
      if (!await isUsableRepoDir(target)) {
        try {
          await _deleteDirRobust(target, messages);
        } catch (_) {}
        throw Exception('${messages.cloneUnusable}: $trimmed');
      }
      return target;
    });
  }

  /// 是否已有本地缓存：裸仓看 HEAD，普通仓看 .git。
  Future<bool> isCached(String repoPath) async {
    final trimmed = repoPath.trim();
    if (!GitUrlDetector.isRemoteUrl(trimmed)) return false;
    if (!_runner.supportsNativeGit) return false;
    try {
      final dir = await cacheDirFor(trimmed);
      if (!await dir.exists()) return false;
      return File('${dir.path}/HEAD').existsSync() ||
          Directory('${dir.path}/.git').existsSync();
    } catch (_) {
      return false;
    }
  }

  /// 计算实际生效的本地目录
  Future<String> resolveEffectiveDir(
      String repoPath, String scope, GitMessages messages) async {
    final base = repoPath.trim().isEmpty ? '.' : repoPath.trim();
    // 去 scope 前导斜杠，避免拼接出绝对路径。
    final s = scope.trim().replaceAll(RegExp(r'^[/\\]+'), '');
    if (!GitUrlDetector.isRemoteUrl(base)) {
      if (s.isEmpty) return base;
      return '${base.replaceAll(RegExp(r'[/\\]+$'), '')}/$s';
    }
    final dir = await resolve(base, messages, fetchIfCached: true);
    if (s.isEmpty) return dir.path;
    return '${dir.path}/$s';
  }
}
