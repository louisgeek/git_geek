import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:git_geek/models/git_commit.dart';

part 'commits_state.freezed.dart';

/// Commits 页面状态（Freezed，不手写 copyWith）。
@freezed
abstract class CommitsState with _$CommitsState {
  const factory CommitsState({
    @Default([]) List<GitCommit> commits,
    @Default([]) List<GitBranch> branches,
    @Default([]) List<GitSubmodule> submodules,
    @Default({}) Map<String, String> submoduleBranches,
    @Default('') String remoteUrl,
    /// 当前分支（'' = 当前 HEAD）
    @Default('') String branch,
    @Default('100') String commitLimit,
    @Default('') String commitQuery,
    @Default(true) bool newestFirst,
    @Default(false) bool isLoadingCommits,
    @Default(false) bool isLoadingBranches,
    @Default(false) bool isLoadingSubmodules,
    @Default(false) bool isCloning,
    @Default('') String cloningInfo,
    String? commitError,
    String? branchError,
    String? submoduleError,
    @Default('') String lastRefreshInfo,
    /// 子模块范围（'' = 主仓库）；与 controller 的 selectedScope 同步。
    @Default('') String scope,
    /// remote 名（与 controller 的 remote 同步，用于 fetchRemoteUrl）。
    @Default('origin') String remoteName,
  }) = _CommitsState;
}

extension CommitsStateX on CommitsState {
  List<GitCommit> get visibleCommits {
    final filtered = commits.filterByQuery(commitQuery);
    return newestFirst ? filtered : filtered.reversed.toList();
  }

  bool get isLoading =>
      isLoadingCommits || isLoadingBranches || isLoadingSubmodules;
}
