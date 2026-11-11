import 'package:git_geek/core/error/app_error.dart';
import 'package:git_geek/core/error/result.dart';
import 'package:git_geek/features/commits/data/sources/git_commit_source.dart';
import 'package:git_geek/core/git/git_url.dart';
import 'package:git_geek/core/git/remote_repo.dart';
import 'package:git_geek/shared/l10n/strings.dart';
import 'package:git_geek/features/commits/domain/commits_repository_contract.dart';
import 'package:git_geek/features/commits/domain/git_commit.dart';
import 'package:logger/logger.dart';

/// Commits/branches/submodules 仓储
/// 约定调用方先调 [resolveEffectiveDir] 一次拿到生效目录，再并行调各 fetch，
/// 避免三次 resolve 触发三次 fetch --tags --prune。
class CommitsRepository implements CommitsRepositoryContract {
  static const _tag = '[commits]';

  final GitCommitDataSource _dataSource;
  final Logger _log;
  final RemoteRepoResolver _resolver;

  CommitsRepository(this._dataSource, this._log, this._resolver);

  /// 计算实际生效目录（含 scope），内部走 RemoteRepoResolver（带缓存/锁）。
  @override
  Future<Result<String>> resolveEffectiveDir(
    String repoPath,
    String scope,
    AppLang lang,
  ) async {
    try {
      return Result.success(
        await _resolver.resolveEffectiveDir(repoPath, scope, lang.gitMessages),
      );
    } catch (e, st) {
      _log.w(
        '$_tag resolveEffectiveDir 失败 $repoPath',
        error: e,
        stackTrace: st,
      );
      return Result.failureOf(
        GitCommandError(cleanError(e), cause: e),
        stackTrace: st,
      );
    }
  }

  /// 远程 URL 且本地无缓存（首次会触发克隆，用于显示 cloning 提示）。
  @override
  Future<bool> isRemoteAndNotCached(String repoPath) async {
    if (!GitUrlDetector.isRemoteUrl(repoPath.trim())) return false;
    return !(await _resolver.isCached(repoPath.trim()));
  }

  /// 拉取提交列表。
  @override
  Future<Result<List<GitCommit>>> fetchCommits(
    String dir,
    String branch,
    int limit,
    AppLang lang,
  ) async {
    final result = await _dataSource.fetchCommits(dir, branch, limit, lang);
    if (result case Failure(:final message, :final cause, :final stackTrace)) {
      _log.w(
        '$_tag fetchCommits 失败 dir=$dir: $message',
        error: cause,
        stackTrace: stackTrace,
      );
    }
    return result;
  }

  /// 拉取分支列表。
  @override
  Future<Result<List<GitBranch>>> fetchBranches(
    String dir,
    AppLang lang,
  ) async {
    final result = await _dataSource.fetchBranches(dir, lang);
    if (result case Failure(:final message, :final cause, :final stackTrace)) {
      _log.w(
        '$_tag fetchBranches 失败 dir=$dir: $message',
        error: cause,
        stackTrace: stackTrace,
      );
    }
    return result;
  }

  /// 拉取子模块现状。
  @override
  Future<Result<List<GitSubmodule>>> fetchSubmodules(
    String dir,
    AppLang lang,
  ) async {
    final result = await _dataSource.fetchSubmodules(dir, lang);
    if (result case Failure(:final message, :final cause, :final stackTrace)) {
      _log.w(
        '$_tag fetchSubmodules 失败 dir=$dir: $message',
        error: cause,
        stackTrace: stackTrace,
      );
    }
    return result;
  }

  /// 拉取远端地址。
  @override
  Future<Result<String>> fetchRemoteUrl(
    String dir,
    String remote,
    AppLang lang,
  ) async {
    final result = await _dataSource.fetchRemoteUrl(dir, remote, lang);
    if (result case Failure(:final message, :final cause, :final stackTrace)) {
      _log.w(
        '$_tag fetchRemoteUrl 失败 dir=$dir: $message',
        error: cause,
        stackTrace: stackTrace,
      );
    }
    return result;
  }

  /// 拉取子模块最近若干条提交（参照面板用，轻量）。
  @override
  Future<Result<List<GitCommit>>> fetchSubmoduleRecentCommits(
    String dir,
    String subPath,
    int limit,
    AppLang lang,
  ) async {
    final result =
        await _dataSource.fetchSubmoduleRecentCommits(dir, subPath, limit, lang);
    if (result case Failure(:final message, :final cause, :final stackTrace)) {
      _log.w(
        '$_tag fetchSubmoduleRecentCommits 失败 $subPath: $message',
        error: cause,
        stackTrace: stackTrace,
      );
    }
    return result;
  }

  /// 拉取子模块当前分支。
  @override
  Future<Result<String>> fetchSubmoduleBranch(
    String dir,
    String subPath,
    AppLang lang,
  ) async {
    final result = await _dataSource.fetchSubmoduleBranch(dir, subPath, lang);
    if (result case Failure(:final message, :final cause, :final stackTrace)) {
      _log.w(
        '$_tag fetchSubmoduleBranch 失败 $subPath: $message',
        error: cause,
        stackTrace: stackTrace,
      );
    }
    return result;
  }
}
