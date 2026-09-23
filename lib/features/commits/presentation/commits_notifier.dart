import 'package:git_geek/features/commits/data/commits_repository.dart';
import 'package:git_geek/features/commits/di/providers.dart';
import 'package:git_geek/features/commits/presentation/commits_state.dart';
import 'package:git_geek/l10n/strings.dart';
import 'package:git_geek/models/git_commit.dart';
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
    late final String dir;
    try {
      dir = await _repo.resolveEffectiveDir(repoPath, scope, lang);
    } catch (e) {
      state = state.copyWith(
        isLoadingCommits: false,
        commitError:
            '${tr.resolveFail}: ${_msg(e) ?? tr.unknownError}',
      );
      // 与老行为一致：resolve 失败也继续刷分支/子模块（各自再 resolve）。
      await loadBranches(repoPath: repoPath, scope: scope, lang: lang);
      await loadSubmodules(repoPath: repoPath, lang: lang);
      return;
    }
    try {
      final needsClone = await _repo.isRemoteAndNotCached(repoPath);
      if (needsClone) {
        state = state.copyWith(isCloning: true, cloningInfo: tr.cloningToCache);
      }
      final n = limit.clamp(1, 5000);
      final trimmedBranch = branch.trim();
      final results = await Future.wait([
        _repo.fetchCommits(dir, trimmedBranch, n, lang),
        _repo.fetchBranches(dir, lang),
        _repo.fetchSubmodules(repoPath, lang),
      ]);
      final commits = results[0] as List<GitCommit>;
      final branches = results[1] as List<GitBranch>;
      final submodules = results[2] as List<GitSubmodule>;

      final subs = await _loadSubmoduleExtras(
          repoPath, submodules, trimmedRemote(remote), lang);

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
    } catch (e) {
      state = state.copyWith(
        isLoadingCommits: false,
        isCloning: false,
        cloningInfo: '',
        commitError: _msg(e) ?? tr.unknownError,
      );
      await loadBranches(repoPath: repoPath, scope: scope, lang: lang);
      await loadSubmodules(repoPath: repoPath, lang: lang);
    }
  }

  Future<void> loadBranches({
    required String repoPath,
    required String scope,
    required AppLang lang,
  }) async {
    final tr = t(lang);
    state = state.copyWith(isLoadingBranches: true, branchError: null);
    try {
      final dir = await _repo.resolveEffectiveDir(repoPath, scope, lang);
      final branches = await _repo.fetchBranches(dir, lang);
      state = state.copyWith(isLoadingBranches: false, branches: branches);
    } catch (e) {
      state = state.copyWith(
        isLoadingBranches: false,
        branchError: _msg(e) ?? tr.unknownError,
      );
    }
  }

  /// 子模块 + remoteUrl + 各子模块当前分支（用主仓 repoPath，与老行为一致）。
  Future<void> loadSubmodules({
    required String repoPath,
    required AppLang lang,
  }) async {
    final tr = t(lang);
    state = state.copyWith(
        isLoadingSubmodules: true, submoduleError: null);
    try {
      final subs = await _repo.fetchSubmodules(repoPath, lang);
      final scope = state.scope;
      final valid = scope.isEmpty || subs.any((e) => e.path == scope);
      state = state.copyWith(
        isLoadingSubmodules: false,
        submodules: subs,
        scope: valid ? scope : '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSubmodules: false,
        submoduleError: _msg(e) ?? tr.unknownError,
      );
    }
    final extras = await _loadSubmoduleExtras(repoPath, state.submodules,
        trimmedRemote(state.remoteName), lang);
    state = state.copyWith(remoteUrl: extras.$1, submoduleBranches: extras.$2);
  }

  Future<(String, Map<String, String>)> _loadSubmoduleExtras(
    String repoPath,
    List<GitSubmodule> subs,
    String remote,
    AppLang lang,
  ) async {
    var remoteUrl = '';
    try {
      remoteUrl = await _repo.fetchRemoteUrl(repoPath, remote, lang);
    } catch (_) {}
    final submoduleBranches = <String, String>{};
    if (subs.isNotEmpty) {
      final branchResults = await Future.wait(subs.map((sub) async {
        try {
          final b =
              await _repo.fetchSubmoduleBranch(repoPath, sub.path, lang);
          return b.trim().isNotEmpty ? MapEntry(sub.path, b.trim()) : null;
        } catch (_) {
          return null;
        }
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
      commitLimit: v.split('').where(_isDigit).take(4).join());
  void setScope(String v) => state = state.copyWith(scope: v);
  void setRemoteName(String v) => state = state.copyWith(remoteName: v);
  void toggleOrder() =>
      state = state.copyWith(newestFirst: !state.newestFirst);

  CommitsRepository get _repo => ref.read(commitsRepositoryProvider);

  String trimmedRemote(String remote) =>
      remote.trim().isEmpty ? 'origin' : remote.trim();

  static bool _isDigit(String c) {
    if (c.isEmpty) return false;
    final u = c.codeUnitAt(0);
    return u >= 48 && u <= 57;
  }

  String? _msg(Object e) {
    final s = e.toString();
    const prefix = 'Exception: ';
    return s.startsWith(prefix) ? s.substring(prefix.length) : s;
  }
}
