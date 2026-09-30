import 'package:git_geek/core/storage/app_prefs.dart';
import 'package:git_geek/data/git_runner.dart';
import 'package:git_geek/data/remote_repo.dart';
import 'package:git_geek/features/commits/presentation/commits_notifier.dart';
import 'package:git_geek/features/tags/presentation/tags_notifier.dart';
import 'package:git_geek/features/workspace/presentation/workspace_state.dart';
import 'package:git_geek/l10n/strings.dart';
import 'package:git_geek/models/git_commit.dart';
import 'package:git_geek/models/git_tag.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'workspace_notifier.g.dart';

/// 应用外壳协调器（原 GitTagController）：持有仓库配置 + tab/范围，
/// tags 数据在 TagsNotifier，commits/branches/submodules 在 CommitsNotifier，
/// 这里只做转发、跨 tab 导航与示例数据。
@Riverpod(keepAlive: true)
class WorkspaceNotifier extends _$WorkspaceNotifier {
  @override
  WorkspaceState build() => const WorkspaceState();

  void _emit(WorkspaceState s) {
    state = s;
  }

  Future<void> init({AppLang? systemDefault}) async {
    // 偏好唯一源：SettingsRepository（同 key 复用老数据，无需 GitTagSettings）。
    final prefs = ref.read(settingsRepositoryProvider);
    final saved = prefs.langCode;
    // 首次使用（无保存记录）时按系统 locale 推断默认语言（含 zh_HK/zh_MO → 繁体）
    final lang =
        saved.isNotEmpty ? AppLang.of(saved) : (systemDefault ?? AppLang.zh);
    final repoPath = prefs.repoPath;
    final remote =
        prefs.remote.trim().isEmpty ? 'origin' : prefs.remote;
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
    ref.read(settingsRepositoryProvider.notifier).setLang(lang.code);
    _emit(state.copyWith(lang: lang));
  }

  // ---- 配置/展示 ----
  Future<void> setRepoPath(String v) async {
    await ref.read(settingsRepositoryProvider.notifier).setRepoPath(v);
    var hint = '';
    try {
      hint = await RemoteRepoResolver.cacheDirHintFor(v);
    } catch (_) {}
    ref.read(commitsProvider.notifier).setScope('');
    _emit(state.copyWith(repoPath: v, selectedScope: '', cacheDirHint: hint));
  }

  void setRemote(String v) {
    ref.read(settingsRepositoryProvider.notifier).setRemote(v);
    ref.read(commitsProvider.notifier).setRemoteName(
        v.trim().isEmpty ? 'origin' : v.trim());
    _emit(state.copyWith(remote: v));
  }

  /// tags 内页签（0 对比总览/1 本地/2 远端）；tags 页与 commits 页的切换走路由。
  void setTagTab(int i) {
    // 页签下标钳制到 0~2，防越界。
    _emit(state.copyWith(selectedTagTab: i.clamp(0, 2)));
  }

  /// 进入 commits 页时调一次：无数据才刷（原 setTab 切到 tab 3 的懒加载）。
  void ensureCommitsLoaded() {
    if (supportsNativeGit && ref.read(commitsProvider).commits.isEmpty) {
      refreshCommits();
    }
  }

  void selectBranch(String name) {
    ref.read(commitsProvider.notifier).setBranch(name);
    refreshCommits();
  }

  void selectScope(String path) {
    ref.read(commitsProvider.notifier).setScope(path);
    _emit(state.copyWith(selectedScope: path));
    refreshAll();
  }

  // ---- 真实读取 ----
  /// tags 唯一源为 TagsNotifier，commits 唯一源为 CommitsNotifier，这里只转发。
  Future<void> refreshLocal() =>
      ref.read(tagsProvider.notifier).loadLocal(
            repoPath: state.repoPath,
            scope: state.selectedScope,
            lang: state.lang,
          );

  Future<void> refreshRemote() =>
      ref.read(tagsProvider.notifier).loadRemote(
            repoPath: state.repoPath,
            remote: state.remote,
            scope: state.selectedScope,
            lang: state.lang,
          );

  Future<void> refreshCommits() {
    final cs = ref.read(commitsProvider);
    return ref.read(commitsProvider.notifier).load(
          repoPath: state.repoPath,
          scope: state.selectedScope,
          branch: cs.branch,
          limit: int.tryParse(cs.commitLimit) ?? 100,
          remote: state.remote,
          lang: state.lang,
        );
  }

  void refreshBranches() =>
      ref.read(commitsProvider.notifier).loadBranches(
            repoPath: state.repoPath,
            scope: state.selectedScope,
            lang: state.lang,
          );

  void refreshSubmodules() =>
      ref.read(commitsProvider.notifier).loadSubmodules(
            repoPath: state.repoPath,
            lang: state.lang,
          );

  void refreshAll() {
    ref.read(tagsProvider.notifier).load(
          repoPath: state.repoPath,
          remote: state.remote,
          scope: state.selectedScope,
          lang: state.lang,
        );
    refreshCommits();
  }

  // ---- 跨页跳转的状态准备（实际路由跳转由各 Page 调 context.go） ----
  void viewCommitForTag(TagCompareItem item) {
    final sha = item.local?.commitSha ?? item.remote?.commitSha;
    ref.read(commitsProvider.notifier).setCommitQuery(
        sha != null && sha.length >= 8 ? sha.substring(0, 8) : (sha ?? item.name));
    if (ref.read(commitsProvider).commits.isEmpty) refreshCommits();
  }

  void viewTagFromCommit(String tagName) {
    final tags = ref.read(tagsProvider.notifier);
    tags.setQuery(tagName);
    tags.setFilter(TagFilter.all);
    _emit(state.copyWith(selectedTagTab: 0));
  }

  void viewSubmoduleChange(String path, String? sha) {
    final commits = ref.read(commitsProvider.notifier);
    commits.setScope(path);
    _emit(state.copyWith(selectedScope: path));
    commits.setCommitQuery(
        (sha != null && sha.length >= 8) ? sha.substring(0, 8) : (sha ?? ''));
    refreshAll();
  }

  void loadSample() {
    // 示例数据直接按来源命名空间构造（本地 refs/tags vs 远端 ls-remote 结果）。
    const local = [
      GitTag(name: 'v1.0.0', commitSha: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2', isAnnotated: true, tagger: 'louis', tagDate: '2026-09-01', tagMessage: '首个正式版', commitAuthor: 'louis', commitDate: '2026-09-01', commitSubject: 'release: 首个正式版'),
      GitTag(name: 'v1.1.0', commitSha: 'b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3', isAnnotated: false, commitAuthor: 'louis', commitDate: '2026-09-05', commitSubject: 'feat: 新增深色模式'),
      GitTag(name: 'v1.2.0', commitSha: 'c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4', isAnnotated: true, tagger: 'louis', tagDate: '2026-09-10', tagMessage: '修复闪退热修复版', commitAuthor: 'louis', commitDate: '2026-09-10', commitSubject: 'fix: 修复启动闪退', commitBody: 'issue #123\n回归测试通过'),
      GitTag(name: 'v2.0.0-rc.1', commitSha: 'd4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5', isAnnotated: false, commitAuthor: 'louis', commitDate: '2026-09-12', commitSubject: 'chore: 2.0 预发布'),
      GitTag(name: 'v2.0.0'),
    ];
    const remote = [
      GitTag(name: 'v1.0.0', commitSha: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2', commitAuthor: 'louis', commitDate: '2026-09-01', commitSubject: 'release: 首个正式版', source: TagSource.remote),
      GitTag(name: 'v1.1.0', commitSha: 'ffffffffffffffffffffffffffffffffffffffff', commitAuthor: 'louis', commitDate: '2026-09-06', commitSubject: 'revert: 回滚深色模式', source: TagSource.remote),
      GitTag(name: 'v1.2.0', commitSha: 'c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4', commitAuthor: 'louis', commitDate: '2026-09-10', commitSubject: 'fix: 修复启动闪退', source: TagSource.remote),
      GitTag(name: 'v1.3.0', commitSha: 'e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6', commitAuthor: 'louis', commitDate: '2026-09-14', commitSubject: 'feat: 新增导出功能', source: TagSource.remote),
    ];
    ref.read(tagsProvider.notifier).setSample(local, remote, state.lang);
    ref.read(commitsProvider.notifier).setSample(
      const [
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
      const [
        GitBranch(name: 'main', isCurrent: true),
        GitBranch(name: 'dev_v2.3.0'),
        GitBranch(name: 'origin/main'),
      ],
      const [
        GitSubmodule(path: 'packages/player',
            sha: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
            branch: 'main'),
        GitSubmodule(path: 'packages/common',
            sha: 'b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3',
            status: SubmoduleStatus.modified),
      ],
      state.lang,
    );
  }

  void clearAll() {
    ref.read(tagsProvider.notifier).clear(state.lang);
    ref.read(commitsProvider.notifier).clear(state.lang);
    _emit(state.copyWith(selectedScope: ''));
    ref.read(commitsProvider.notifier).setScope('');
  }
}
