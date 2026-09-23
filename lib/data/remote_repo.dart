import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:git_geek/data/git_runner.dart';
import 'package:git_geek/data/git_url.dart';
import 'package:git_geek/l10n/strings.dart';
import 'package:path_provider/path_provider.dart';

/// 语言按调用透传 [AppLang]，无全局语言状态（调用方见 Repository/Notifier）。

/// 同一 URL 的串行锁
class _AsyncLock {
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

/// 远程仓库解析器。
/// 移动/桌面端：URL 自动克隆到缓存并增量更新；Web 等无 git 平台：抛友好错误。
class RemoteRepoResolver {
  static final Map<String, _AsyncLock> _locks = {};
  static _AsyncLock _lockFor(String url) =>
      _locks.putIfAbsent(url, () => _AsyncLock());

  static Future<Directory> _cacheRoot() async {
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      final base = (appData != null && appData.trim().isNotEmpty)
          ? Directory('${appData.trim()}\\GitGeek')
          : Directory(
              '${Platform.environment['USERPROFILE'] ?? '.'}\\.GitGeek');
      final dir = Directory('${base.path}\\cache');
      await dir.create(recursive: true);
      return dir;
    }
    try {
      final support = await getApplicationSupportDirectory();
      final dir = Directory('${support.path}/GitGeek/cache');
      await dir.create(recursive: true);
      return dir;
    } catch (_) {
      final home = Platform.environment['HOME'] ?? '.';
      final dir = Directory('$home/.GitGeek/cache');
      await dir.create(recursive: true);
      return dir;
    }
  }

  static String repoNameFromUrl(String url) {
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

  static Future<Directory> cacheDirFor(String url) async {
    final root = await _cacheRoot();
    final name =
        repoNameFromUrl(url).replaceAll(RegExp(r'[^\w.\-]'), '_');
    final short = sha1.convert(utf8.encode(url.trim())).toString().substring(0, 10);
    return Directory('${root.path}/$name-$short');
  }

  /// 仅展示用：同步拼出缓存路径（不触发 IO 检测）。
  static Future<String> cacheDirHintFor(String url) async {
    if (!GitUrlDetector.isRemoteUrl(url)) return '';
    try {
      return (await cacheDirFor(url)).path;
    } catch (_) {
      return '';
    }
  }

  static Future<bool> isUsableRepoDir(Directory dir) async {
    if (!await dir.exists()) return false;
    final r = await gitRunner.run(dir.path, ['rev-parse', '--git-dir']);
    return r.ok;
  }

  static Future<void> _deleteDirRobust(Directory dir, AppLang lang) async {
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
        throw Exception('${t(lang).cacheCleanFail}: ${dir.path}');
      }
    }
  }

  static Future<void> _cloneSmart(
    Directory target,
    String url,
    AppLang lang,
    void Function(String)? onProgress,
  ) async {
    var r = await gitRunner.run(null, [
      'clone',
      '--filter=blob:none',
      '--progress',
      url,
      target.path,
    ], onProgress: onProgress);
    if (r.ok) return;
    await _deleteDirRobust(target, lang);
    onProgress?.call(t(lang).filterFallback);
    r = await gitRunner.run(null, [
      'clone',
      '--progress',
      url,
      target.path,
    ], onProgress: onProgress);
    if (!r.ok) throw Exception(r.stderr);
  }

  static Future<void> _fetch(Directory repoDir, String url) async {
    var r = await gitRunner.run(
        repoDir.path, ['remote', 'set-url', 'origin', url]);
    if (!r.ok) throw Exception(r.stderr);
    r = await gitRunner.run(
        repoDir.path, ['fetch', '--tags', '--prune', 'origin']);
    if (!r.ok) throw Exception(r.stderr);
    await gitRunner.run(repoDir.path, ['merge', '--ff-only', 'FETCH_HEAD']);
  }

  static Future<Directory> resolve(
    String repoPath,
    AppLang lang, {
    bool fetchIfCached = true,
    void Function(String)? onProgress,
  }) async {
    final tr = t(lang);
    final trimmed = repoPath.trim();
    if (trimmed.isEmpty) return Directory.current;
    if (!GitUrlDetector.isRemoteUrl(trimmed)) {
      final f = Directory(trimmed);
      if (!await f.exists()) {
        throw Exception('${tr.dirNotExist}: $trimmed');
      }
      return f;
    }
    if (!supportsNativeGit) {
      throw Exception(tr.platformUnsupported('Web'));
    }
    final target = await cacheDirFor(trimmed);
    return _lockFor(trimmed).run(() async {
      if (await isUsableRepoDir(target)) {
        if (fetchIfCached) {
          onProgress?.call(tr.updatingCache);
          try {
            await _fetch(target, trimmed);
          } catch (e) {
            onProgress?.call('${tr.updateStaleCache}: $e');
          }
        }
        return target;
      }
      await _deleteDirRobust(target, lang);
      onProgress?.call(tr.cloningCache);
      try {
        await _cloneSmart(target, trimmed, lang, onProgress);
      } catch (e) {
        try {
          await _deleteDirRobust(target, lang);
        } catch (_) {}
        rethrow;
      }
      if (!await isUsableRepoDir(target)) {
        try {
          await _deleteDirRobust(target, lang);
        } catch (_) {}
        throw Exception('${tr.cloneUnusable}: $trimmed');
      }
      return target;
    });
  }

  static Future<bool> isCached(String repoPath) async {
    final trimmed = repoPath.trim();
    if (!GitUrlDetector.isRemoteUrl(trimmed)) return false;
    if (!supportsNativeGit) return false;
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
  static Future<String> resolveEffectiveDir(
      String repoPath, String scope, AppLang lang) async {
    final base = repoPath.trim().isEmpty ? '.' : repoPath.trim();
    final s = scope.trim().replaceAll(RegExp(r'^[/\\]+'), '');
    if (!GitUrlDetector.isRemoteUrl(base)) {
      if (s.isEmpty) return base;
      return '${base.replaceAll(RegExp(r'[/\\]+$'), '')}/$s';
    }
    final dir = await resolve(base, lang, fetchIfCached: true);
    if (s.isEmpty) return dir.path;
    return '${dir.path}/$s';
  }
}
