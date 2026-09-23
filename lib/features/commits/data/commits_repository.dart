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
  final Logger _log;
  final GitCommitDataSource _ds;
  CommitsRepository(this._log, this._ds);

  /// 计算实际生效目录（含 scope），内部走 RemoteRepoResolver（带缓存/锁）。
  Future<String> resolveEffectiveDir(
      String repoPath, String scope, AppLang lang) {
    return RemoteRepoResolver.resolveEffectiveDir(repoPath, scope, lang);
  }

  /// 远程 URL 且本地无缓存（首次会触发克隆，用于显示 cloning 提示）。
  Future<bool> isRemoteAndNotCached(String repoPath) async {
    if (!GitUrlDetector.isRemoteUrl(repoPath.trim())) return false;
    return !(await RemoteRepoResolver.isCached(repoPath.trim()));
  }

  Future<List<GitCommit>> fetchCommits(
    String dir,
    String branch,
    int limit,
    AppLang lang,
  ) async {
    try {
      return await _ds.fetchCommits(dir, branch, limit, lang);
    } catch (e, st) {
      _log.w('[commits] fetchCommits 失败 dir=$dir', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<GitBranch>> fetchBranches(String dir, AppLang lang) async {
    try {
      return await _ds.fetchBranches(dir, lang);
    } catch (e, st) {
      _log.w('[commits] fetchBranches 失败 dir=$dir', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<GitSubmodule>> fetchSubmodules(
      String dir, AppLang lang) async {
    try {
      return await _ds.fetchSubmodules(dir, lang);
    } catch (e, st) {
      _log.w('[commits] fetchSubmodules 失败 dir=$dir',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<String> fetchRemoteUrl(
      String dir, String remote, AppLang lang) async {
    try {
      return await _ds.fetchRemoteUrl(dir, remote, lang);
    } catch (e, st) {
      _log.w('[commits] fetchRemoteUrl 失败 dir=$dir',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<String> fetchSubmoduleBranch(
      String dir, String subPath, AppLang lang) async {
    try {
      return await _ds.fetchSubmoduleBranch(dir, subPath, lang);
    } catch (e, st) {
      _log.w('[commits] fetchSubmoduleBranch 失败 $subPath',
          error: e, stackTrace: st);
      rethrow;
    }
  }
}
