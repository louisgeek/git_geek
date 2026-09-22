import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:git_geek/src/data/git_commit_source.dart';
import 'package:git_geek/src/data/git_runner.dart';
import 'package:git_geek/src/data/git_tag_source.dart';
import 'package:git_geek/src/data/git_url.dart';
import 'package:git_geek/src/data/remote_repo.dart';
import 'package:git_geek/src/data/settings.dart';
import 'package:git_geek/src/l10n/strings.dart';
import 'package:git_geek/src/logic/git_log_parser.dart';
import 'package:git_geek/src/logic/git_tag_parser.dart';
import 'package:git_geek/src/logic/semver.dart';
import 'package:git_geek/src/models/git_commit.dart';
import 'package:git_geek/src/models/git_tag.dart';

part 'controller.g.dart';

/// UI 状态（对标原 GitTagUiState，派生 getter 保持同一语义）
class GitTagUiState {
  final String repoPath;
  final String remote;
  final AppLang lang;
  final List<GitTag> localTags;
  final List<GitTag> remoteTags;
  final String searchQuery;
  final TagSortMode sortMode;
  final TagFilter filter;
  final int selectedTab;
  final String branch;
  final String commitLimit;
  final String commitQuery;
  final List<GitCommit> commits;
  final List<GitBranch> branches;
  final bool isLoadingCommits;
  final bool isLoadingBranches;
  final String? commitError;
  final String? branchError;
  final String commitPaste;
  final String branchPaste;
  final bool commitNewestFirst;
  final List<GitSubmodule> submodules;
  final String selectedScope;
  final bool isLoadingSubmodules;
  final String? submoduleError;
  final String submodulePaste;
  final String remoteUrl;
  final Map<String, String> submoduleBranches;
  final bool isLoadingLocal;
  final bool isLoadingRemote;
  final String? localError;
  final String? remoteError;
  final bool isCloning;
  final String cloningInfo;
  final String cacheDirHint;
  final String localPaste;
  final String remotePaste;
  final String lastRefreshInfo;

  const GitTagUiState({
    this.repoPath = '',
    this.remote = 'origin',
    this.lang = AppLang.zh,
    this.localTags = const [],
    this.remoteTags = const [],
    this.searchQuery = '',
    this.sortMode = TagSortMode.semverDesc,
    this.filter = TagFilter.all,
    this.selectedTab = 0,
    this.branch = '',
    this.commitLimit = '100',
    this.commitQuery = '',
    this.commits = const [],
    this.branches = const [],
    this.isLoadingCommits = false,
    this.isLoadingBranches = false,
    this.commitError,
    this.branchError,
    this.commitPaste = '',
    this.branchPaste = '',
    this.commitNewestFirst = true,
    this.submodules = const [],
    this.selectedScope = '',
    this.isLoadingSubmodules = false,
    this.submoduleError,
    this.submodulePaste = '',
    this.remoteUrl = '',
    this.submoduleBranches = const {},
    this.isLoadingLocal = false,
    this.isLoadingRemote = false,
    this.localError,
    this.remoteError,
    this.isCloning = false,
    this.cloningInfo = '',
    this.cacheDirHint = '',
    this.localPaste = '',
    this.remotePaste = '',
    this.lastRefreshInfo = '',
  });

  GitTagUiState copyWith({
    String? repoPath,
    String? remote,
    AppLang? lang,
    List<GitTag>? localTags,
    List<GitTag>? remoteTags,
    String? searchQuery,
    TagSortMode? sortMode,
    TagFilter? filter,
    int? selectedTab,
    String? branch,
    String? commitLimit,
    String? commitQuery,
    List<GitCommit>? commits,
    List<GitBranch>? branches,
    bool? isLoadingCommits,
    bool? isLoadingBranches,
    String? Function()? commitError,
    String? Function()? branchError,
    String? commitPaste,
    String? branchPaste,
    bool? commitNewestFirst,
    List<GitSubmodule>? submodules,
    String? selectedScope,
    bool? isLoadingSubmodules,
    String? Function()? submoduleError,
    String? submodulePaste,
    String? remoteUrl,
    Map<String, String>? submoduleBranches,
    bool? isLoadingLocal,
    bool? isLoadingRemote,
    String? Function()? localError,
    String? Function()? remoteError,
    bool? isCloning,
    String? cloningInfo,
    String? cacheDirHint,
    String? localPaste,
    String? remotePaste,
    String? lastRefreshInfo,
  }) {
    return GitTagUiState(
      repoPath: repoPath ?? this.repoPath,
      remote: remote ?? this.remote,
      lang: lang ?? this.lang,
      localTags: localTags ?? this.localTags,
      remoteTags: remoteTags ?? this.remoteTags,
      searchQuery: searchQuery ?? this.searchQuery,
      sortMode: sortMode ?? this.sortMode,
      filter: filter ?? this.filter,
      selectedTab: selectedTab ?? this.selectedTab,
      branch: branch ?? this.branch,
      commitLimit: commitLimit ?? this.commitLimit,
      commitQuery: commitQuery ?? this.commitQuery,
      commits: commits ?? this.commits,
      branches: branches ?? this.branches,
      isLoadingCommits: isLoadingCommits ?? this.isLoadingCommits,
      isLoadingBranches: isLoadingBranches ?? this.isLoadingBranches,
      commitError: commitError != null ? commitError() : this.commitError,
      branchError: branchError != null ? branchError() : this.branchError,
      commitPaste: commitPaste ?? this.commitPaste,
      branchPaste: branchPaste ?? this.branchPaste,
      commitNewestFirst: commitNewestFirst ?? this.commitNewestFirst,
      submodules: submodules ?? this.submodules,
      selectedScope: selectedScope ?? this.selectedScope,
      isLoadingSubmodules: isLoadingSubmodules ?? this.isLoadingSubmodules,
      submoduleError:
          submoduleError != null ? submoduleError() : this.submoduleError,
      submodulePaste: submodulePaste ?? this.submodulePaste,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      submoduleBranches: submoduleBranches ?? this.submoduleBranches,
      isLoadingLocal: isLoadingLocal ?? this.isLoadingLocal,
      isLoadingRemote: isLoadingRemote ?? this.isLoadingRemote,
      localError: localError != null ? localError() : this.localError,
      remoteError: remoteError != null ? remoteError() : this.remoteError,
      isCloning: isCloning ?? this.isCloning,
      cloningInfo: cloningInfo ?? this.cloningInfo,
      cacheDirHint: cacheDirHint ?? this.cacheDirHint,
      localPaste: localPaste ?? this.localPaste,
      remotePaste: remotePaste ?? this.remotePaste,
      lastRefreshInfo: lastRefreshInfo ?? this.lastRefreshInfo,
    );
  }

  List<TagCompareItem> get allCompare =>
      buildCompareItems(localTags, remoteTags);
  TagStats get stats => calcStats(allCompare);
  List<TagCompareItem> get visibleCompare => allCompare
      .filterByStatus(filter)
      .filterByQuery(searchQuery)
      .sortedByMode(sortMode);
  List<GitTag> get visibleLocal =>
      localTags.filterByQuery(searchQuery).sortedByMode(sortMode);
  List<GitTag> get visibleRemote =>
      remoteTags.filterByQuery(searchQuery).sortedByMode(sortMode);
  List<GitCommit> get visibleCommits {
    final filtered = commits.filterByQuery(commitQuery);
    return commitNewestFirst ? filtered : filtered.reversed.toList();
  }

  bool get isLoading =>
      isLoadingLocal || isLoadingRemote || isLoadingCommits || isCloning;
}

/// 控制器（对标原 GitTagViewModel；Riverpod @riverpod 注解实现）
@Riverpod(keepAlive: true)
class GitTagController extends _$GitTagController {
  @override
  GitTagUiState build() => const GitTagUiState();

  void _emit(GitTagUiState s) {
    state = s;
  }

  Future<void> init() async {
    await GitTagSettings.ensureInit();
    final lang = AppLang.of(GitTagSettings.loadLang());
    final repoPath = GitTagSettings.loadRepoPath();
    final remote =
        GitTagSettings.loadRemote().trim().isEmpty ? 'origin' : GitTagSettings.loadRemote();
    setResolverLang(lang);
    setTagDataSourceLang(lang);
    setCommitDataSourceLang(lang);
    var hint = '';
    try {
      hint = await RemoteRepoResolver.cacheDirHintFor(repoPath);
    } catch (_) {}
    _emit(state.copyWith(
      repoPath: repoPath,
      remote: remote,
      lang: lang,
      cacheDirHint: hint,
    ));
  }

  // ---- 语言 ----
  void setLang(AppLang lang) {
    GitTagSettings.saveLang(lang.code);
    setResolverLang(lang);
    setTagDataSourceLang(lang);
    setCommitDataSourceLang(lang);
    _emit(state.copyWith(lang: lang));
  }

  // ---- 配置/展示 ----
  Future<void> setRepoPath(String v) async {
    GitTagSettings.saveRepoPath(v);
    var hint = '';
    try {
      hint = await RemoteRepoResolver.cacheDirHintFor(v);
    } catch (_) {}
    _emit(state.copyWith(
      repoPath: v,
      selectedScope: '',
      submodules: [],
      submoduleError: () => null,
      localError: () => null,
      remoteError: () => null,
      commitError: () => null,
      branchError: () => null,
      isCloning: false,
      cloningInfo: '',
      cacheDirHint: hint,
    ));
  }

  void setRemote(String v) {
    GitTagSettings.saveRemote(v);
    _emit(state.copyWith(remote: v, remoteError: () => null));
  }

  void setSearch(String v) => _emit(state.copyWith(searchQuery: v));
  void setSort(TagSortMode v) => _emit(state.copyWith(sortMode: v));
  void setFilter(TagFilter v) => _emit(state.copyWith(filter: v));
  void setTab(int i) {
    _emit(state.copyWith(selectedTab: i));
    if (i == 3 &&
        supportsNativeGit &&
        state.commits.isEmpty &&
        state.commitPaste.trim().isEmpty) {
      refreshCommits();
    }
  }

  void setLocalPaste(String v) => _emit(state.copyWith(localPaste: v));
  void setRemotePaste(String v) => _emit(state.copyWith(remotePaste: v));
  void setBranch(String v) =>
      _emit(state.copyWith(branch: v, commitError: () => null));
  void setCommitLimit(String v) => _emit(state.copyWith(
      commitLimit: v.split('').where(_isDigit).take(4).join()));
  void setCommitQuery(String v) => _emit(state.copyWith(commitQuery: v));
  void setCommitPaste(String v) => _emit(state.copyWith(commitPaste: v));
  void setBranchPaste(String v) => _emit(state.copyWith(branchPaste: v));
  void setSubmodulePaste(String v) =>
      _emit(state.copyWith(submodulePaste: v));
  void toggleCommitOrder() =>
      _emit(state.copyWith(commitNewestFirst: !state.commitNewestFirst));

  void selectBranch(String name) {
    _emit(state.copyWith(branch: name, commitError: () => null));
    refreshCommits();
  }

  void selectScope(String path) {
    _emit(state.copyWith(selectedScope: path));
    refreshAll();
  }

  static bool _isDigit(String c) {
    if (c.isEmpty) return false;
    final u = c.codeUnitAt(0);
    return u >= 48 && u <= 57;
  }

  Future<String> _effectiveDir(GitTagUiState s) =>
      RemoteRepoResolver.resolveEffectiveDir(s.repoPath, s.selectedScope);

  // ---- 真实读取 ----
  Future<void> refreshLocal() async {
    final s = state;
    _emit(state.copyWith(isLoadingLocal: true, localError: () => null));
    // 对标原版：effectiveDir 失败包 resolveFail 前缀
    late final String repoPath;
    try {
      repoPath = await _effectiveDir(s);
    } catch (e) {
      final t = strings(state.lang);
      _emit(state.copyWith(
        isLoadingLocal: false,
        localError: () =>
            '${t.resolveFail}: ${_msg(e) ?? t.unknownError}',
      ));
      return;
    }
    try {
      final needsClone = GitUrlDetector.isRemoteUrl(s.repoPath) &&
          !(await RemoteRepoResolver.isCached(s.repoPath));
      if (needsClone) {
        _emit(state.copyWith(
            isCloning: true, cloningInfo: strings(state.lang).cloningToCache));
      }
      final tags = await GitTagDataSource.fetchLocalTags(repoPath);
      final t = strings(state.lang);
      _emit(state.copyWith(isCloning: false, cloningInfo: ''));
      _emit(state.copyWith(
        isLoadingLocal: false,
        localTags: tags,
        lastRefreshInfo:
            needsClone ? t.clonedTagsOk(tags.length) : t.localTagsOk(tags.length),
      ));
    } catch (e) {
      final t = strings(state.lang);
      _emit(state.copyWith(
        isCloning: false,
        cloningInfo: '',
        isLoadingLocal: false,
        localError: () => _msg(e) ?? t.unknownError,
      ));
    }
  }

  Future<void> refreshRemote() async {
    final s = state;
    _emit(state.copyWith(isLoadingRemote: true, remoteError: () => null));
    late final String dir;
    try {
      dir = await _effectiveDir(s);
    } catch (e) {
      final t = strings(state.lang);
      _emit(state.copyWith(
        isLoadingRemote: false,
        remoteError: () =>
            '${t.resolveFail}: ${_msg(e) ?? t.unknownError}',
      ));
      return;
    }
    try {
      final needsClone = GitUrlDetector.isRemoteUrl(s.repoPath) &&
          !(await RemoteRepoResolver.isCached(s.repoPath));
      if (needsClone) {
        _emit(state.copyWith(
            isCloning: true, cloningInfo: strings(state.lang).cloningToCache));
      }
      final tags = await GitTagDataSource.fetchRemoteTags(
          dir, s.remote.trim().isEmpty ? 'origin' : s.remote);
      final t = strings(state.lang);
      _emit(state.copyWith(isCloning: false, cloningInfo: ''));
      _emit(state.copyWith(
        isLoadingRemote: false,
        remoteTags: tags,
        lastRefreshInfo: needsClone
            ? t.clonedTagsOk(tags.length)
            : t.remoteTagsOk(tags.length),
      ));
    } catch (e) {
      final t = strings(state.lang);
      _emit(state.copyWith(
        isCloning: false,
        cloningInfo: '',
        isLoadingRemote: false,
        remoteError: () => _msg(e) ?? t.unknownError,
      ));
    }
  }

  void refreshAll() {
    refreshLocal();
    refreshRemote();
    refreshCommits();
  }

  Future<void> refreshCommits() async {
    final s = state;
    final limit = int.tryParse(s.commitLimit)?.clamp(1, 5000) ?? 100;
    _emit(state.copyWith(isLoadingCommits: true, commitError: () => null));
    late final String dir;
    try {
      dir = await _effectiveDir(s);
    } catch (e) {
      final t = strings(state.lang);
      _emit(state.copyWith(
        isLoadingCommits: false,
        commitError: () =>
            '${t.resolveFail}: ${_msg(e) ?? t.unknownError}',
      ));
      refreshBranches();
      refreshSubmodules();
      return;
    }
    try {
      final needsClone = GitUrlDetector.isRemoteUrl(s.repoPath) &&
          !(await RemoteRepoResolver.isCached(s.repoPath));
      if (needsClone) {
        _emit(state.copyWith(
            isCloning: true, cloningInfo: strings(state.lang).cloningToCache));
      }
      final commits =
          await GitCommitDataSource.fetchCommits(dir, s.branch, limit);
      final t = strings(state.lang);
      _emit(state.copyWith(isCloning: false, cloningInfo: ''));
      _emit(state.copyWith(
        isLoadingCommits: false,
        commits: attachSubmoduleRecordInfo(commits),
        lastRefreshInfo: needsClone
            ? t.clonedCommitsOk(commits.length)
            : t.commitsOk(commits.length),
      ));
    } catch (e) {
      final t = strings(state.lang);
      _emit(state.copyWith(
        isCloning: false,
        cloningInfo: '',
        isLoadingCommits: false,
        commitError: () => _msg(e) ?? t.unknownError,
      ));
    }
    refreshBranches();
    refreshSubmodules();
  }

  Future<void> refreshBranches() async {
    final s = state;
    _emit(state.copyWith(isLoadingBranches: true, branchError: () => null));
    late final String dir;
    try {
      dir = await _effectiveDir(s);
    } catch (e) {
      final t = strings(state.lang);
      _emit(state.copyWith(
        isLoadingBranches: false,
        branchError: () =>
            '${t.resolveFail}: ${_msg(e) ?? t.unknownError}',
      ));
      return;
    }
    try {
      final branches = await GitCommitDataSource.fetchBranches(dir);
      _emit(state.copyWith(isLoadingBranches: false, branches: branches));
    } catch (e) {
      final t = strings(state.lang);
      _emit(state.copyWith(
        isLoadingBranches: false,
        branchError: () => _msg(e) ?? t.unknownError,
      ));
    }
  }

  void parseCommitPaste() {
    final raw = state.commitPaste;
    final commits = attachSubmoduleRecordInfo(GitLogParser.parse(raw));
    final t = strings(state.lang);
    _emit(state.copyWith(
      commits: commits,
      commitError: () =>
          (commits.isEmpty && raw.trim().isNotEmpty) ? t.commitsParseFail : null,
      lastRefreshInfo: t.commitsParsedOk(commits.length),
    ));
  }

  void parseBranchPaste() {
    final raw = state.branchPaste;
    final branches = GitLogParser.parseBranches(raw);
    final t = strings(state.lang);
    _emit(state.copyWith(
      branches: branches,
      branchError: () =>
          (branches.isEmpty && raw.trim().isNotEmpty) ? t.branchesParseFail : null,
      lastRefreshInfo: t.branchesParsedOk(branches.length),
    ));
  }

  Future<void> refreshSubmodules() async {
    final repoPath = state.repoPath;
    _emit(state.copyWith(
        isLoadingSubmodules: true, submoduleError: () => null));
    try {
      final subs = await GitCommitDataSource.fetchSubmodules(repoPath);
      final scope = state.selectedScope;
      final valid = scope.isEmpty || subs.any((e) => e.path == scope);
      _emit(state.copyWith(
        isLoadingSubmodules: false,
        submodules: subs,
        selectedScope: valid ? scope : '',
      ));
    } catch (e) {
      final t = strings(state.lang);
      _emit(state.copyWith(
        isLoadingSubmodules: false,
        submoduleError: () => _msg(e) ?? t.unknownError,
      ));
    }
    try {
      final remote = state.remote.trim().isEmpty ? 'origin' : state.remote;
      final url = await GitCommitDataSource.fetchRemoteUrl(repoPath, remote);
      _emit(state.copyWith(remoteUrl: url));
    } catch (_) {}
    final subs = state.submodules;
    if (subs.isNotEmpty) {
      final branches = <String, String>{};
      for (final sub in subs) {
        try {
          final b = await GitCommitDataSource.fetchSubmoduleBranch(
              repoPath, sub.path);
          if (b.trim().isNotEmpty) branches[sub.path] = b;
        } catch (_) {}
      }
      _emit(state.copyWith(submoduleBranches: branches));
    }
  }

  void parseSubmodulePaste() {
    final raw = state.submodulePaste;
    final subs = GitSubmoduleParser.parse(raw);
    final t = strings(state.lang);
    _emit(state.copyWith(
      submodules: subs,
      submoduleError: () =>
          (subs.isEmpty && raw.trim().isNotEmpty) ? t.submodulesParseFail : null,
      lastRefreshInfo: t.submodulesParsedOk(subs.length),
    ));
  }

  void viewCommitForTag(TagCompareItem item) {
    final sha = item.local?.commitSha ?? item.remote?.commitSha;
    _emit(state.copyWith(
        commitQuery: sha != null && sha.length >= 8
            ? sha.substring(0, 8)
            : (sha ?? item.name),
        selectedTab: 3));
    if (state.commits.isEmpty) refreshCommits();
  }

  void viewTagFromCommit(String tagName) {
    _emit(state.copyWith(
        searchQuery: tagName, filter: TagFilter.all, selectedTab: 0));
  }

  void viewSubmoduleChange(String path, String? sha) {
    _emit(state.copyWith(
        selectedScope: path,
        commitQuery: (sha != null && sha.length >= 8)
            ? sha.substring(0, 8)
            : (sha ?? ''),
        selectedTab: 3));
    refreshAll();
  }

  void locateCommit(String sha) {
    _emit(state.copyWith(
        commitQuery: sha.length >= 8 ? sha.substring(0, 8) : sha,
        selectedTab: 3));
  }

  void parseLocalPaste() {
    final raw = state.localPaste;
    final tags = GitTagParser.parseLocal(raw);
    final t = strings(state.lang);
    _emit(state.copyWith(
      localTags: tags,
      localError: () =>
          (tags.isEmpty && raw.trim().isNotEmpty) ? t.tagParseFail : null,
      lastRefreshInfo: t.localPasteOk(tags.length),
    ));
  }

  void parseRemotePaste() {
    final raw = state.remotePaste;
    final tags = GitTagParser.parseRemote(raw);
    final t = strings(state.lang);
    _emit(state.copyWith(
      remoteTags: tags,
      remoteError: () =>
          (tags.isEmpty && raw.trim().isNotEmpty) ? t.tagParseFail : null,
      lastRefreshInfo: t.remotePasteOk(tags.length),
    ));
  }

  void loadSample() {
    const local = [
      GitTag(name: 'v1.0.0', commitSha: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2', isAnnotated: true, tagger: 'louis', tagDate: '2026-09-01', tagMessage: '首个正式版', commitAuthor: 'louis', commitDate: '2026-09-01', commitSubject: 'release: 首个正式版', source: TagSource.sample),
      GitTag(name: 'v1.1.0', commitSha: 'b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3', isAnnotated: false, commitAuthor: 'louis', commitDate: '2026-09-05', commitSubject: 'feat: 新增深色模式', source: TagSource.sample),
      GitTag(name: 'v1.2.0', commitSha: 'c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4', isAnnotated: true, tagger: 'louis', tagDate: '2026-09-10', tagMessage: '修复闪退热修复版', commitAuthor: 'louis', commitDate: '2026-09-10', commitSubject: 'fix: 修复启动闪退', commitBody: 'issue #123\n回归测试通过', source: TagSource.sample),
      GitTag(name: 'v2.0.0-rc.1', commitSha: 'd4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5', isAnnotated: false, commitAuthor: 'louis', commitDate: '2026-09-12', commitSubject: 'chore: 2.0 预发布', source: TagSource.sample),
      GitTag(name: 'v2.0.0', source: TagSource.sample),
    ];
    const remote = [
      GitTag(name: 'v1.0.0', commitSha: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2', commitAuthor: 'louis', commitDate: '2026-09-01', commitSubject: 'release: 首个正式版', source: TagSource.sample),
      GitTag(name: 'v1.1.0', commitSha: 'ffffffffffffffffffffffffffffffffffffffff', commitAuthor: 'louis', commitDate: '2026-09-06', commitSubject: 'revert: 回滚深色模式', source: TagSource.sample),
      GitTag(name: 'v1.2.0', commitSha: 'c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4', commitAuthor: 'louis', commitDate: '2026-09-10', commitSubject: 'fix: 修复启动闪退', source: TagSource.sample),
      GitTag(name: 'v1.3.0', commitSha: 'e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6', commitAuthor: 'louis', commitDate: '2026-09-14', commitSubject: 'feat: 新增导出功能', source: TagSource.sample),
    ];
    final t = strings(state.lang);
    _emit(state.copyWith(
      localTags: local.map((e) => e.copyWith(source: TagSource.local)).toList(),
      remoteTags: remote.map((e) => e.copyWith(source: TagSource.remote)).toList(),
      commits: const [
        GitCommit(
            sha: 'c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',
            parents: ['b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3'],
            author: 'louis',
            date: '2026-09-10',
            refs: 'HEAD -> main, tag: v1.2.0',
            tags: ['v1.2.0'],
            subject: 'fix: 修复启动闪退',
            body: 'issue #123\n回归测试通过',
            submoduleChanges: [
              SubmoduleChange(
                  path: 'packages/player',
                  oldSha: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
                  newSha: 'c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',
                  oldAuthor: 'louis',
                  oldDate: '2026-09-01',
                  oldSubject: 'release: 首个正式版',
                  newAuthor: 'louis',
                  newDate: '2026-09-10',
                  newSubject: 'fix: 修复启动闪退'),
            ]),
        GitCommit(
            sha: 'b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3',
            parents: ['a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2'],
            author: 'louis',
            date: '2026-09-05',
            refs: 'tag: v1.1.0',
            tags: ['v1.1.0'],
            subject: 'feat: 新增深色模式'),
        GitCommit(
            sha: 'ffffffffffffffffffffffffffffffffffffffff',
            parents: ['b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3'],
            author: 'louis',
            date: '2026-09-06',
            refs: 'origin/main',
            subject: 'revert: 回滚深色模式'),
        GitCommit(
            sha: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
            author: 'louis',
            date: '2026-09-01',
            refs: 'tag: v1.0.0',
            tags: ['v1.0.0'],
            subject: 'release: 首个正式版'),
      ],
      branches: const [
        GitBranch(name: 'main', isCurrent: true),
        GitBranch(name: 'dev_v2.3.0'),
        GitBranch(name: 'origin/main'),
      ],
      submodules: const [
        GitSubmodule(path: 'packages/player',
            sha: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
            branch: 'main'),
        GitSubmodule(path: 'packages/common',
            sha: 'b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3',
            status: SubmoduleStatus.modified),
      ],
      localError: () => null,
      remoteError: () => null,
      commitError: () => null,
      lastRefreshInfo: t.sampleLoaded,
    ));
  }

  void clearAll() {
    final t = strings(state.lang);
    _emit(state.copyWith(
      localTags: [],
      remoteTags: [],
      commits: [],
      branches: [],
      localPaste: '',
      remotePaste: '',
      commitPaste: '',
      branchPaste: '',
      submodulePaste: '',
      localError: () => null,
      remoteError: () => null,
      commitError: () => null,
      branchError: () => null,
      submoduleError: () => null,
      selectedScope: '',
      submodules: [],
      searchQuery: '',
      commitQuery: '',
      filter: TagFilter.all,
      lastRefreshInfo: t.cleared,
    ));
  }

  String? _msg(Object e) {
    final s = e.toString();
    const prefix = 'Exception: ';
    return s.startsWith(prefix) ? s.substring(prefix.length) : s;
  }
}
