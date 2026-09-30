import 'package:git_geek/core/result.dart';
import 'package:git_geek/data/git_commit_source.dart';
import 'package:git_geek/data/git_url.dart';
import 'package:git_geek/data/remote_repo.dart';
import 'package:git_geek/l10n/strings.dart';
import 'package:git_geek/models/git_commit.dart';
import 'package:logger/logger.dart';

/// Commits/branches/submodules 仓储：Notifier 只调这里，不直调 DataSource。
/// 约定调用方先调 [resolveEffectiveDir] 一次拿到生效目录，再并行调各 fetch，
/// 避免老 controller 里三次 resolve 触发三次 fetch --tags --prune。
/// 装配见 `features/commits/di/providers.dart`。
class CommitsRepository {
  static const _tag = '[commits]';

  final Logger _log;
  final GitCommitDataSource _dataSource;

  CommitsRepository(this._log, this._dataSource);

  /// 计算实际生效目录（含 scope），内部走 RemoteRepoResolver（带缓存/锁）。
  Future<Result<String>> resolveEffectiveDir(
    String repoPath,
    String scope,
    AppLang lang,
  ) async {
    try {
      return Result.ok(
        await RemoteRepoResolver.resolveEffectiveDir(repoPath, scope, lang),
      );
    } catch (e, st) {
      _log.w(
        '$_tag resolveEffectiveDir 失败 $repoPath',
        error: e,
        stackTrace: st,
      );
      return Result.err(cleanError(e), cause: e, stackTrace: st);
    }
  }

  /// 远程 URL 且本地无缓存（首次会触发克隆，用于显示 cloning 提示）。
  Future<bool> isRemoteAndNotCached(String repoPath) async {
    if (!GitUrlDetector.isRemoteUrl(repoPath.trim())) return false;
    return !(await RemoteRepoResolver.isCached(repoPath.trim()));
  }

  /// 拉取提交列表。
  Future<Result<List<GitCommit>>> fetchCommits(
    String dir,
    String branch,
    int limit,
    AppLang lang,
  ) async {
    final result = await _dataSource.fetchCommits(dir, branch, limit, lang);
    if (result case Err(:final message, :final cause, :final stackTrace)) {
      _log.w(
        '$_tag fetchCommits 失败 dir=$dir: $message',
        error: cause,
        stackTrace: stackTrace,
      );
    }
    return result;
  }

  /// 拉取分支列表。
  Future<Result<List<GitBranch>>> fetchBranches(
    String dir,
    AppLang lang,
  ) async {
    final result = await _dataSource.fetchBranches(dir, lang);
    if (result case Err(:final message, :final cause, :final stackTrace)) {
      _log.w(
        '$_tag fetchBranches 失败 dir=$dir: $message',
        error: cause,
        stackTrace: stackTrace,
      );
    }
    return result;
  }

  /// 拉取子模块现状。
  Future<Result<List<GitSubmodule>>> fetchSubmodules(
    String dir,
    AppLang lang,
  ) async {
    final result = await _dataSource.fetchSubmodules(dir, lang);
    if (result case Err(:final message, :final cause, :final stackTrace)) {
      _log.w(
        '$_tag fetchSubmodules 失败 dir=$dir: $message',
        error: cause,
        stackTrace: stackTrace,
      );
    }
    return result;
  }

  /// 拉取远端地址。
  Future<Result<String>> fetchRemoteUrl(
    String dir,
    String remote,
    AppLang lang,
  ) async {
    final result = await _dataSource.fetchRemoteUrl(dir, remote, lang);
    if (result case Err(:final message, :final cause, :final stackTrace)) {
      _log.w(
        '$_tag fetchRemoteUrl 失败 dir=$dir: $message',
        error: cause,
        stackTrace: stackTrace,
      );
    }
    return result;
  }

  /// 拉取子模块当前分支。
  Future<Result<String>> fetchSubmoduleBranch(
    String dir,
    String subPath,
    AppLang lang,
  ) async {
    final result = await _dataSource.fetchSubmoduleBranch(dir, subPath, lang);
    if (result case Err(:final message, :final cause, :final stackTrace)) {
      _log.w(
        '$_tag fetchSubmoduleBranch 失败 $subPath: $message',
        error: cause,
        stackTrace: stackTrace,
      );
    }
    return result;
  }
}
