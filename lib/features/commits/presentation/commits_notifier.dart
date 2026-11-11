import 'package:git_geek/core/config/app_config.dart';
import 'package:git_geek/core/error/result.dart';
import 'package:git_geek/features/commits/domain/commits_repository_contract.dart';
import 'package:git_geek/features/commits/commits_providers.dart';
import 'package:git_geek/features/commits/presentation/commits_state.dart';
import 'package:git_geek/shared/l10n/strings.dart';
import 'package:git_geek/features/commits/domain/git_commit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'commits_notifier.g.dart';

/// Commits 子 Notifier（新架构）：唯一持有 commits/branches/submodules +
/// 查询/排序/limit + 各自 loading/error。调用方传 repoPath/scope/remote/lang，
/// 内部一次 resolve 后并行拉取。
@riverpod
class CommitsNotifier extends _$CommitsNotifier {
  @override
  CommitsState build() => const CommitsState();

  /// 全量刷新：commits + branches + submodules（+ remoteUrl/子模块分支）。
  Future<void> load({
    required String repoPath,
    required String scope,
    required String branch,
    required int limit,
    required String remote,
    required AppLang lang,
  }) async {
    final tr = t(lang);
    state = state.copyWith(isLoadingCommits: true, commitError: null);
    final dirResult = await _repo.resolveEffectiveDir(repoPath, scope, lang);
    if (!ref.mounted) return;
    final dir = dirResult.valueOrNull;
    if (dir == null) {
      state = state.copyWith(
        isLoadingCommits: false,
        commitError:
            '${tr.resolveFail}: ${dirResult.errorOrNull ?? tr.unknownError}',
      );
      // 与老行为一致：resolve 失败也继续刷分支/子模块（各自再 resolve）。
      await loadBranches(repoPath: repoPath, scope: scope, lang: lang);
      await loadSubmodules(repoPath: repoPath, lang: lang);
      return;
    }
    final needsClone = await _repo.isRemoteAndNotCached(repoPath);
    if (!ref.mounted) return;
    if (needsClone) {
      state = state.copyWith(isCloning: true, cloningInfo: tr.cloningToCache);
    }
    // 条数钳制到 1~5000，防过大拖慢解析。
    final n = limit.clamp(1, AppConfig.commitFetchLimitMax);
    final trimmedBranch = branch.trim();
    final results = await Future.wait([
      _repo.fetchCommits(dir, trimmedBranch, n, lang),
      _repo.fetchBranches(dir, lang),
      _repo.fetchSubmodules(repoPath, lang),
    ]);
    final commitsResult = results[0] as Result<List<GitCommit>>;
    final branchesResult = results[1] as Result<List<GitBranch>>;
    final submodulesResult = results[2] as Result<List<GitSubmodule>>;
    final commits = commitsResult.valueOrNull;
    final branches = branchesResult.valueOrNull;
    final submodules = submodulesResult.valueOrNull;
    if (commits == null || branches == null || submodules == null) {
      state = state.copyWith(
        isLoadingCommits: false,
        isCloning: false,
        cloningInfo: '',
        commitError: commitsResult.errorOrNull ??
            branchesResult.errorOrNull ??
            submodulesResult.errorOrNull ??
            tr.unknownError,
      );
      await loadBranches(repoPath: repoPath, scope: scope, lang: lang);
      await loadSubmodules(repoPath: repoPath, lang: lang);
      return;
    }

    final subs = await _loadSubmoduleExtras(
        repoPath, submodules, trimmedRemote(remote), lang);
    if (!ref.mounted) return;

    state = state.copyWith(
      isLoadingCommits: false,
      isCloning: false,
      cloningInfo: '',
      commits: commits,
      branches: branches,
      submodules: submodules,
      submoduleBranches: subs.$2,
      remoteUrl: subs.$1,
      branch: trimmedBranch,
      lastRefreshInfo: needsClone
          ? tr.clonedCommitsOk(commits.length)
          : tr.commitsOk(commits.length),
    );
  }

  Future<void> loadBranches({
    required String repoPath,
    required String scope,
    required AppLang lang,
  }) async {
    state = state.copyWith(isLoadingBranches: true, branchError: null);
    switch (await _repo.resolveEffectiveDir(repoPath, scope, lang)) {
      case Failure(:final message):
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoadingBranches: false,
          branchError: message,
        );
        return;
      case Success(value: final dir):
        switch (await _repo.fetchBranches(dir, lang)) {
          case Success(value: final branches):
            if (!ref.mounted) return;
            state = state.copyWith(
                isLoadingBranches: false, branches: branches);
          case Failure(:final message):
            if (!ref.mounted) return;
            state = state.copyWith(
              isLoadingBranches: false,
              branchError: message,
            );
        }
    }
  }

  /// 各子模块最近提交（参照面板用）：并行逐个拉取，best-effort。
  /// 刻意不进 [load] 主链，每个子模块只跑一条轻量 git log。
  Future<void> loadSubmoduleLogs({
    required String repoPath,
    required int limit,
    required AppLang lang,
  }) async {
    final subs = state.submodules;
    if (subs.isEmpty) {
      if (state.submoduleLogs.isNotEmpty || state.isLoadingSubmoduleLogs) {
        state = state.copyWith(
          submoduleLogs: const {},
          isLoadingSubmoduleLogs: false,
        );
      }
      return;
    }
    state = state.copyWith(isLoadingSubmoduleLogs: true);
    // 未初始化的子库没有工作目录，拉 log 必然失败，直接跳过（面板显示为空）。
    final pullable =
        subs.where((e) => e.status != SubmoduleStatus.uninitialized).toList();
    final results = await Future.wait(pullable.map((sub) async {
      final r = await _repo.fetchSubmoduleRecentCommits(
          repoPath, sub.path, limit, lang);
      return MapEntry(sub.path, r.valueOrNull ?? const <GitCommit>[]);
    }));
    if (!ref.mounted) return;
    state = state.copyWith(
      isLoadingSubmoduleLogs: false,
      submoduleLogs: {for (final e in results) e.key: e.value},
    );
  }

  /// 子模块 + remoteUrl + 各子模块当前分支（用主仓 repoPath，与老行为一致）。
  Future<void> loadSubmodules({
    required String repoPath,
    required AppLang lang,
  }) async {
    state = state.copyWith(
        isLoadingSubmodules: true, submoduleError: null);
    switch (await _repo.fetchSubmodules(repoPath, lang)) {
      case Failure(:final message):
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoadingSubmodules: false,
          submoduleError: message,
        );
      case Success(value: final subs):
        final scope = state.scope;
        final valid = scope.isEmpty || subs.any((e) => e.path == scope);
        state = state.copyWith(
          isLoadingSubmodules: false,
          submodules: subs,
          scope: valid ? scope : '',
        );
    }
    final extras = await _loadSubmoduleExtras(repoPath, state.submodules,
        trimmedRemote(state.remoteName), lang);
    if (!ref.mounted) return;
    state = state.copyWith(remoteUrl: extras.$1, submoduleBranches: extras.$2);
  }

  Future<(String, Map<String, String>)> _loadSubmoduleExtras(
    String repoPath,
    List<GitSubmodule> subs,
    String remote,
    AppLang lang,
  ) async {
    // 附加信息 best-effort：失败只留空，不影响主流程。
    final remoteUrl =
        (await _repo.fetchRemoteUrl(repoPath, remote, lang)).valueOrNull ?? '';
    final submoduleBranches = <String, String>{};
    if (subs.isNotEmpty) {
      final branchResults = await Future.wait(subs.map((sub) async {
        final b = (await _repo.fetchSubmoduleBranch(repoPath, sub.path, lang))
            .valueOrNull;
        return b != null && b.trim().isNotEmpty
            ? MapEntry(sub.path, b.trim())
            : null;
      }));
      for (final e in branchResults) {
        if (e != null) submoduleBranches[e.key] = e.value;
      }
    }
    return (remoteUrl, submoduleBranches);
  }

  void setSample(
    List<GitCommit> commits,
    List<GitBranch> branches,
    List<GitSubmodule> submodules,
    AppLang lang,
  ) {
    state = state.copyWith(
      commits: commits,
      branches: branches,
      submodules: submodules,
      commitError: null,
      branchError: null,
      submoduleError: null,
      lastRefreshInfo: t(lang).sampleLoaded,
    );
  }

  void clear(AppLang lang) {
    state = state.copyWith(
      commits: const [],
      branches: const [],
      submodules: const [],
      submoduleBranches: const {},
      remoteUrl: '',
      commitQuery: '',
      commitError: null,
      branchError: null,
      submoduleError: null,
      lastRefreshInfo: t(lang).cleared,
    );
  }

  // ---- 输入 ----
  void setBranch(String v) => state = state.copyWith(branch: v);
  void setCommitQuery(String v) => state = state.copyWith(commitQuery: v);
  void setCommitLimit(String v) => state = state.copyWith(
      // 仅保留数字并截前 4 位，防超长输入。
      commitLimit: v.split('').where(_isDigit).take(4).join());
  void setScope(String v) => state = state.copyWith(scope: v);
  void setRemoteName(String v) => state = state.copyWith(remoteName: v);
  void toggleOrder() =>
      state = state.copyWith(newestFirst: !state.newestFirst);

  CommitsRepositoryContract get _repo =>
      ref.read(commitsRepositoryProvider);

  /// 去空 remote 名：空回退 `origin`。
  String trimmedRemote(String remote) =>
      remote.trim().isEmpty ? 'origin' : remote.trim();

  static bool _isDigit(String c) {
    if (c.isEmpty) return false;
    // ASCII 码 48-57 即字符 '0'-'9'。
    final u = c.codeUnitAt(0);
    return u >= 48 && u <= 57;
  }
}
