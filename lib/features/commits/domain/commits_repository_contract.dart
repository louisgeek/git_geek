import 'package:git_geek/core/error/result.dart';
import 'package:git_geek/features/commits/domain/git_commit.dart';
import 'package:git_geek/core/config/app_lang.dart';

/// Commits/branches/submodules 仓储契约（domain 层）。
///
/// 约定调用方先调 [resolveEffectiveDir] 一次拿到生效目录，再并行调各 fetch，
/// 避免三次 resolve 触发三次 fetch --tags --prune。
/// 实现（`CommitsRepository`）在 data 层，由组合根注入。
abstract interface class CommitsRepositoryContract {
  /// 计算实际生效目录（含 scope），内部走 RemoteRepoResolver（带缓存/锁）。
  Future<Result<String>> resolveEffectiveDir(
    String repoPath,
    String scope,
    AppLang lang,
  );

  /// 远程 URL 且本地无缓存（首次会触发克隆，用于显示 cloning 提示）。
  Future<bool> isRemoteAndNotCached(String repoPath);

  /// 拉取提交列表。
  Future<Result<List<GitCommit>>> fetchCommits(
    String dir,
    String branch,
    int limit,
    AppLang lang,
  );

  /// 拉取分支列表。
  Future<Result<List<GitBranch>>> fetchBranches(String dir, AppLang lang);

  /// 拉取子模块现状。
  Future<Result<List<GitSubmodule>>> fetchSubmodules(String dir, AppLang lang);

  /// 拉取远端地址。
  Future<Result<String>> fetchRemoteUrl(
    String dir,
    String remote,
    AppLang lang,
  );

  /// 拉取子模块最近若干条提交（参照面板用，轻量）。
  Future<Result<List<GitCommit>>> fetchSubmoduleRecentCommits(
    String dir,
    String subPath,
    int limit,
    AppLang lang,
  );

  /// 拉取子模块当前分支。
  Future<Result<String>> fetchSubmoduleBranch(
    String dir,
    String subPath,
    AppLang lang,
  );
}
