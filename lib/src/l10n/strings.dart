/// 全量 UI 文案：抽象 + 中英两个实现（对标原 AppStrings.kt）
enum AppLang {
  zh('zh'),
  en('en');

  final String code;
  const AppLang(this.code);

  static AppLang of(String? code) {
    final c = code?.trim().toLowerCase();
    return AppLang.values.firstWhere(
      (e) => e.code == c,
      orElse: () => AppLang.zh,
    );
  }
}

const String appVersion = '1.0';

AppStrings strings(AppLang lang) => lang == AppLang.en ? enStrings : zhStrings;

String gitLogPasteCommand(AppLang lang) =>
    _gitLogPasteCommandTemplate.replaceAll(
        '[分支名]', strings(lang).logCmdBranchHint);

const String _gitLogPasteCommandTemplate =
    'git log --topo-order -m --raw --no-abbrev --date=format:%Y-%m-%d %H:%M --format="===COMMIT===%nsha: %H%nparents: %P%nauthor: %an%ndate: %ad%nrefs: %D%nsubject: %s%n%b%n===END===" -n 500 [分支名]';

const String gitLogPasteCommandTemplate = _gitLogPasteCommandTemplate;

abstract class AppStrings {
  String get subtitleDesktop;
  String get subtitleNoGit;
  String get langZh;
  String get langEn;
  String get about;
  String get aboutTitle;
  String get aboutVersionLabel;
  String get aboutCopyright;
  String get close;
  String get repoCardTitle;
  String get repoPathLabel;
  String get repoPathPlaceholder;
  String get remoteUrlHint;
  String get cachePrefix;
  String get copy;
  String get remoteNameLabel;
  String get remoteNamePlaceholder;
  String get scopePrefix;
  String get mainRepo;
  String get submoduleWord;
  String get btnRefreshLocal;
  String get btnRefreshRemote;
  String get btnRefreshAll;
  String get btnSample;
  String get btnClear;
  String get cloningFallback;
  String get loadingLocal;
  String get loadingRemote;
  String get loadingCommits;
  String get errLocalPrefix;
  String get errRemotePrefix;
  String get errSubmodulePrefix;
  String get statLocal;
  String get statRemote;
  String get statSynced;
  String get statOnlyLocal;
  String get statOnlyRemote;
  String get diverged;
  String divergedWarn(int count);
  String get searchTagLabel;
  String get sortLabel;
  String get sortSemver;
  String get sortName;
  String get filterAll;
  String get tabCompare;
  String get tabCommits;
  String get emptyCompare;
  String get badgeOnlyLocal;
  String get badgeOnlyRemote;
  String get noSha;
  String get missing;
  String get detailTitle;
  String get missingPushHint;
  String get missingPullHint;
  String get explainSynced;
  String explainOnlyLocal(String tag);
  String explainOnlyRemote(String tag);
  String get explainDiverged;
  String get viewCommitBtn;
  String get expandHint;
  String get annotatedShort;
  String get lightweightShort;
  String get pureNameNoSha;
  String get fullSide;
  String get tagTypePrefix;
  String get annotatedLong;
  String get lightweightLong;
  String get tagNotesPrefix;
  String get emptyLocalTab;
  String get emptyRemoteTab;
  String get currentScopePrefix;
  String get searchCommitLabel;
  String get currentBranchChip;
  String get errBranchPrefix;
  String get branchLabel;
  String get branchPlaceholder;
  String get limitLabel;
  String get btnRefreshCommits;
  String get newestFirst;
  String get oldestFirst;
  String get loadingCommitsLong;
  String get errCommitPrefix;
  String get emptyCommits;
  String get emptySubject;
  String get addedWord;
  String get removedWord;
  String get fromWord;
  String get mergeEdited;
  String get newValueFrom;
  String get oldFromMerge;
  String get oldFrom;
  String get lastSwitch;
  String get newValueUnknown;
  String get silentDrop;
  String get keptWord;
  String get copied;
  String get pasteTitle;
  String get collapse;
  String get expand;
  String get pasteTagDesc;
  String get localPasteLabel;
  String get localPastePlaceholder;
  String get parseLocalPaste;
  String get previewWord;
  String get remotePasteLabel;
  String get remotePastePlaceholder;
  String get parseRemotePaste;
  String get pasteCommitDesc;
  String get logCmdBranchHint;
  String get commitPasteLabel;
  String get commitPastePlaceholder;
  String get parseCommitPaste;
  String get branchPasteLabel;
  String get branchPastePlaceholder;
  String get parseBranchPaste;
  String get submodulePasteLabel;
  String get submodulePastePlaceholder;
  String get parseSubmodulePaste;
  String get resolveFail;
  String get unknownError;
  String get cloningToCache;
  String localTagsOk(int n);
  String clonedTagsOk(int n);
  String remoteTagsOk(int n);
  String commitsOk(int n);
  String clonedCommitsOk(int n);
  String get commitsParseFail;
  String commitsParsedOk(int n);
  String get branchesParseFail;
  String branchesParsedOk(int n);
  String get submodulesParseFail;
  String submodulesParsedOk(int n);
  String get tagParseFail;
  String localPasteOk(int n);
  String remotePasteOk(int n);
  String get sampleLoaded;
  String get cleared;
  String get localTagsFail;
  String get remoteTagsFail;
  String get commitsFail;
  String get branchesFail;
  String get submodulesFail;
  String get remoteUrlFail;
  String get submoduleBranchFail;
  String get dirName;
  String get dirNotExist;
  String get gitNotInstalled;
  String get gitRunFail;
  String get updatingCache;
  String get updateStaleCache;
  String get cloningCache;
  String get filterFallback;
  String get cacheCleanFail;
  String get cloneUnusable;
  String get cmdLog;
  String get cmdTagLocal;
  String noNativeGit(String platform, String cmd);
  String platformUnsupported(String platform);
  String get subUninitialized;
  String get subModified;
  String get subConflict;
}

class _ZhStrings extends AppStrings {
  @override
  String get subtitleDesktop => '桌面端: 支持本地目录或远程 URL(https/ssh), 自动克隆到缓存; 也支持粘贴导入';
  @override
  String get subtitleNoGit => '当前平台无本地 git,用下方「粘贴导入」展示任意仓库';
  @override
  String get langZh => '中文';
  @override
  String get langEn => 'English';
  @override
  String get about => '关于';
  @override
  String get aboutTitle => '关于 GitGeek';
  @override
  String get aboutVersionLabel => '版本';
  @override
  String get aboutCopyright => '© 2026 GitGeek';
  @override
  String get close => '关闭';
  @override
  String get repoCardTitle => '仓库配置(任意仓库)';
  @override
  String get repoPathLabel => '仓库路径(本地目录 或 远程 URL)';
  @override
  String get repoPathPlaceholder => 'D:/code/my-repo  或  https://github.com/owner/repo.git';
  @override
  String get remoteUrlHint => '远程 URL: 首次刷新将自动克隆到本地缓存, 之后增量更新';
  @override
  String get cachePrefix => '缓存';
  @override
  String get copy => '复制';
  @override
  String get remoteNameLabel => '远程名或 URL';
  @override
  String get remoteNamePlaceholder => 'origin 或 https://github.com/owner/repo.git';
  @override
  String get scopePrefix => '范围';
  @override
  String get mainRepo => '主仓库';
  @override
  String get submoduleWord => '子模块';
  @override
  String get btnRefreshLocal => '刷新本地';
  @override
  String get btnRefreshRemote => '刷新远程';
  @override
  String get btnRefreshAll => '一键刷新';
  @override
  String get btnSample => '示例数据';
  @override
  String get btnClear => '清空';
  @override
  String get cloningFallback => '正在克隆远程仓库…';
  @override
  String get loadingLocal => '读取本地中… ';
  @override
  String get loadingRemote => '读取远程中…';
  @override
  String get loadingCommits => '读取提交中… ';
  @override
  String get errLocalPrefix => '本地';
  @override
  String get errRemotePrefix => '远程';
  @override
  String get errSubmodulePrefix => '子模块';
  @override
  String get statLocal => '本地';
  @override
  String get statRemote => '远程';
  @override
  String get statSynced => '已同步';
  @override
  String get statOnlyLocal => '仅本地';
  @override
  String get statOnlyRemote => '仅远程';
  @override
  String get diverged => '不一致';
  @override
  String divergedWarn(int count) => '注意: 有 $count 个同名 tag 指向不同 commit(不一致),请检查是否误移动 tag';
  @override
  String get searchTagLabel => '搜索 tag / sha / 注释 / 作者';
  @override
  String get sortLabel => '排序';
  @override
  String get sortSemver => '语义版本';
  @override
  String get sortName => '名称';
  @override
  String get filterAll => '全部';
  @override
  String get tabCompare => '对比总览';
  @override
  String get tabCommits => '提交记录';
  @override
  String get emptyCompare => '暂无数据:点「一键刷新」/「示例数据」,或用下方粘贴导入';
  @override
  String get badgeOnlyLocal => '仅本地·待推送';
  @override
  String get badgeOnlyRemote => '仅远程·待拉取';
  @override
  String get noSha => '无sha';
  @override
  String get missing => '缺失';
  @override
  String get detailTitle => '详情';
  @override
  String get missingPushHint => '—(缺失,需推送)';
  @override
  String get missingPullHint => '—(缺失,需拉取)';
  @override
  String get explainSynced => '说明: 两边一致,无需操作';
  @override
  String explainOnlyLocal(String tag) => '说明: 仅本地存在, 可执行 git push origin $tag 推送';
  @override
  String explainOnlyRemote(String tag) => '说明: 仅远程存在, 可执行 git fetch origin tag $tag 拉取';
  @override
  String get explainDiverged => '说明: 同名但 sha 不同, 可能 tag 被移动, 请核对后再决定覆盖';
  @override
  String get viewCommitBtn => '查看提交';
  @override
  String get expandHint => '点击展开详情';
  @override
  String get annotatedShort => '附注';
  @override
  String get lightweightShort => '轻量';
  @override
  String get pureNameNoSha => 'sha: —(纯名称列表,无 sha)';
  @override
  String get fullSide => '完整';
  @override
  String get tagTypePrefix => '类型';
  @override
  String get annotatedLong => '附注标签';
  @override
  String get lightweightLong => '轻量标签';
  @override
  String get tagNotesPrefix => 'tag 注释';
  @override
  String get emptyLocalTab => '本地暂无 tag';
  @override
  String get emptyRemoteTab => '远程暂无 tag';
  @override
  String get currentScopePrefix => '当前范围';
  @override
  String get searchCommitLabel => '搜索提交 / sha / 作者 / tag';
  @override
  String get currentBranchChip => '当前分支';
  @override
  String get errBranchPrefix => '分支';
  @override
  String get branchLabel => '分支(空=当前)';
  @override
  String get branchPlaceholder => 'main / HEAD / --all';
  @override
  String get limitLabel => '条数';
  @override
  String get btnRefreshCommits => '刷新提交';
  @override
  String get newestFirst => '新到旧';
  @override
  String get oldestFirst => '旧到新';
  @override
  String get loadingCommitsLong => '读取提交记录中…';
  @override
  String get errCommitPrefix => '提交';
  @override
  String get emptyCommits => '暂无提交:点「刷新提交」/「示例数据」,或用下方粘贴导入';
  @override
  String get emptySubject => '(空提交信息)';
  @override
  String get addedWord => '新增';
  @override
  String get removedWord => '移除';
  @override
  String get fromWord => '从';
  @override
  String get mergeEdited => '→(merge手工改)';
  @override
  String get newValueFrom => '↑ 新值来自  ';
  @override
  String get oldFromMerge => '旧值由 merge 引入  ';
  @override
  String get oldFrom => '旧值由  ';
  @override
  String get lastSwitch => '上次切换  ';
  @override
  String get newValueUnknown => '↑ 新值来源未定位(调大条数重刷可补)';
  @override
  String get silentDrop => '⚠ merge 静默丢弃';
  @override
  String get keptWord => '保留了';
  @override
  String get copied => '已复制';
  @override
  String get pasteTitle => '粘贴导入(全平台通用)';
  @override
  String get collapse => '收起';
  @override
  String get expand => '展开';
  @override
  String get pasteTagDesc =>
      '本地粘贴 `git show-ref -d --tags`(推荐,含 commit)或 `git tag -l` 输出;远程粘贴 `git ls-remote --tags origin` 输出,即可对比任意仓库。注:粘贴导入无提交注释,桌面端直读自动附带提交信息(远程需 fetch 过)';
  @override
  String get localPasteLabel => '本地输出粘贴';
  @override
  String get localPastePlaceholder => 'v1.0.0\nv1.1.0\n… 或 <sha> refs/tags/v1.0.0';
  @override
  String get parseLocalPaste => '解析本地粘贴';
  @override
  String get previewWord => '预览';
  @override
  String get remotePasteLabel => '远程输出粘贴';
  @override
  String get remotePastePlaceholder => '<sha>\trefs/tags/v1.0.0\n<sha>\trefs/tags/v1.0.0^{}';
  @override
  String get parseRemotePaste => '解析远程粘贴';
  @override
  String get pasteCommitDesc => '提交记录粘贴: 先在仓库执行以下命令, 把输出粘贴到下面';
  @override
  String get logCmdBranchHint => '[分支名]';
  @override
  String get commitPasteLabel => '提交输出粘贴';
  @override
  String get commitPastePlaceholder => '===COMMIT===\nsha: <sha>\n…\n===END===';
  @override
  String get parseCommitPaste => '解析提交粘贴';
  @override
  String get branchPasteLabel => '分支输出粘贴(`git branch -a`)';
  @override
  String get branchPastePlaceholder => '* main\n  dev\n  remotes/origin/main';
  @override
  String get parseBranchPaste => '解析分支粘贴';
  @override
  String get submodulePasteLabel => '子模块输出粘贴(`git submodule status`)';
  @override
  String get submodulePastePlaceholder => ' 2b699ab… packages/player (main)';
  @override
  String get parseSubmodulePaste => '解析子模块粘贴';
  @override
  String get resolveFail => '仓库解析失败';
  @override
  String get unknownError => '未知错误';
  @override
  String get cloningToCache => '正在克隆远程仓库到缓存…';
  @override
  String localTagsOk(int n) => '本地刷新成功 $n 个';
  @override
  String clonedTagsOk(int n) => '已克隆并刷新 $n 个';
  @override
  String remoteTagsOk(int n) => '远程刷新成功 $n 个';
  @override
  String commitsOk(int n) => '提交记录刷新成功 $n 条';
  @override
  String clonedCommitsOk(int n) => '已克隆并刷新 $n 条';
  @override
  String get commitsParseFail => '未解析到提交, 请用上述 git log 命令生成输出';
  @override
  String commitsParsedOk(int n) => '提交粘贴解析 $n 条';
  @override
  String get branchesParseFail => '未解析到分支, 请粘贴 `git branch -a` 输出';
  @override
  String branchesParsedOk(int n) => '分支粘贴解析 $n 个';
  @override
  String get submodulesParseFail => '未解析到子模块, 请粘贴 `git submodule status` 输出';
  @override
  String submodulesParsedOk(int n) => '子模块粘贴解析 $n 个';
  @override
  String get tagParseFail => '未解析到 tag, 请检查格式';
  @override
  String localPasteOk(int n) => '本地粘贴解析 $n 个';
  @override
  String remotePasteOk(int n) => '远程粘贴解析 $n 个';
  @override
  String get sampleLoaded => '已载入示例数据';
  @override
  String get cleared => '已清空';
  @override
  String get localTagsFail => '本地 tag 读取失败';
  @override
  String get remoteTagsFail => '远程 tag 读取失败';
  @override
  String get commitsFail => '提交记录读取失败';
  @override
  String get branchesFail => '分支列表读取失败';
  @override
  String get submodulesFail => '子模块列表读取失败';
  @override
  String get remoteUrlFail => '读取 remote URL 失败';
  @override
  String get submoduleBranchFail => '读取子模块分支失败';
  @override
  String get dirName => '目录';
  @override
  String get dirNotExist => '目录不存在';
  @override
  String get gitNotInstalled => '无法执行 git, 请确认已安装并在 PATH 中';
  @override
  String get gitRunFail => '无法执行 git';
  @override
  String get updatingCache => '更新缓存仓库…';
  @override
  String get updateStaleCache => '更新失败, 使用旧缓存';
  @override
  String get cloningCache => '正在克隆到缓存…';
  @override
  String get filterFallback => '过滤克隆失败, 改用完整克隆…';
  @override
  String get cacheCleanFail => '缓存目录无法清理(可能被其他程序占用), 请手动删除后重试';
  @override
  String get cloneUnusable => '克隆后仓库仍不可用, 请检查地址/权限后重试';
  @override
  String get cmdLog => '上述 git log 命令';
  @override
  String get cmdTagLocal => '`git tag` 或 `git show-ref --tags`';
  @override
  String noNativeGit(String platform, String cmd) =>
      '$platform 端无法直接执行 git 命令, 请用下方「粘贴导入」: 粘贴 $cmd 的输出后点解析';
  @override
  String platformUnsupported(String platform) => '$platform 端不支持';
  @override
  String get subUninitialized => '未初始化';
  @override
  String get subModified => '有改动';
  @override
  String get subConflict => '冲突';
}

class _EnStrings extends AppStrings {
  @override
  String get subtitleDesktop =>
      'Desktop: local dirs or remote URLs (https/ssh) with auto-clone cache; paste import also supported';
  @override
  String get subtitleNoGit => 'No local git on this platform; use "Paste import" below for any repo';
  @override
  String get langZh => '中文';
  @override
  String get langEn => 'English';
  @override
  String get about => 'About';
  @override
  String get aboutTitle => 'About GitGeek';
  @override
  String get aboutVersionLabel => 'Version';
  @override
  String get aboutCopyright => '© 2026 GitGeek';
  @override
  String get close => 'Close';
  @override
  String get repoCardTitle => 'Repository (any repo)';
  @override
  String get repoPathLabel => 'Repo path (local dir or remote URL)';
  @override
  String get repoPathPlaceholder => 'D:/code/my-repo or https://github.com/owner/repo.git';
  @override
  String get remoteUrlHint => 'Remote URL: auto-clones to local cache on first refresh, then incremental updates';
  @override
  String get cachePrefix => 'Cache';
  @override
  String get copy => 'Copy';
  @override
  String get remoteNameLabel => 'Remote name or URL';
  @override
  String get remoteNamePlaceholder => 'origin or https://github.com/owner/repo.git';
  @override
  String get scopePrefix => 'Scope';
  @override
  String get mainRepo => 'Main repo';
  @override
  String get submoduleWord => 'Submodule';
  @override
  String get btnRefreshLocal => 'Refresh local';
  @override
  String get btnRefreshRemote => 'Refresh remote';
  @override
  String get btnRefreshAll => 'Refresh all';
  @override
  String get btnSample => 'Sample data';
  @override
  String get btnClear => 'Clear';
  @override
  String get cloningFallback => 'Cloning remote repo…';
  @override
  String get loadingLocal => 'Loading local… ';
  @override
  String get loadingRemote => 'Loading remote…';
  @override
  String get loadingCommits => 'Loading commits… ';
  @override
  String get errLocalPrefix => 'Local';
  @override
  String get errRemotePrefix => 'Remote';
  @override
  String get errSubmodulePrefix => 'Submodule';
  @override
  String get statLocal => 'Local';
  @override
  String get statRemote => 'Remote';
  @override
  String get statSynced => 'Synced';
  @override
  String get statOnlyLocal => 'Local only';
  @override
  String get statOnlyRemote => 'Remote only';
  @override
  String get diverged => 'Diverged';
  @override
  String divergedWarn(int count) =>
      'Warning: $count same-name tags point to different commits; check for accidental tag moves';
  @override
  String get searchTagLabel => 'Search tags / sha / message / author';
  @override
  String get sortLabel => 'Sort';
  @override
  String get sortSemver => 'SemVer';
  @override
  String get sortName => 'Name';
  @override
  String get filterAll => 'All';
  @override
  String get tabCompare => 'Compare';
  @override
  String get tabCommits => 'Commits';
  @override
  String get emptyCompare => 'No data: tap "Refresh all" / "Sample data", or use paste import below';
  @override
  String get badgeOnlyLocal => 'Local only · to push';
  @override
  String get badgeOnlyRemote => 'Remote only · to pull';
  @override
  String get noSha => 'no sha';
  @override
  String get missing => 'missing';
  @override
  String get detailTitle => 'Details';
  @override
  String get missingPushHint => '—(missing, needs push)';
  @override
  String get missingPullHint => '—(missing, needs pull)';
  @override
  String get explainSynced => 'Note: both sides match, nothing to do';
  @override
  String explainOnlyLocal(String tag) => 'Note: local only; run `git push origin $tag` to push';
  @override
  String explainOnlyRemote(String tag) => 'Note: remote only; run `git fetch origin tag $tag` to pull';
  @override
  String get explainDiverged => 'Note: same name but different sha; the tag may have been moved, verify before overwriting';
  @override
  String get viewCommitBtn => 'View commits';
  @override
  String get expandHint => 'Tap to expand';
  @override
  String get annotatedShort => 'Annotated';
  @override
  String get lightweightShort => 'Lightweight';
  @override
  String get pureNameNoSha => 'sha: —(name-only list, no sha)';
  @override
  String get fullSide => 'Full';
  @override
  String get tagTypePrefix => 'Type';
  @override
  String get annotatedLong => 'Annotated tag';
  @override
  String get lightweightLong => 'Lightweight tag';
  @override
  String get tagNotesPrefix => 'tag notes';
  @override
  String get emptyLocalTab => 'No local tags';
  @override
  String get emptyRemoteTab => 'No remote tags';
  @override
  String get currentScopePrefix => 'Scope';
  @override
  String get searchCommitLabel => 'Search commits / sha / author / tag';
  @override
  String get currentBranchChip => 'Current branch';
  @override
  String get errBranchPrefix => 'Branches';
  @override
  String get branchLabel => 'Branch (empty=current)';
  @override
  String get branchPlaceholder => 'main / HEAD / --all';
  @override
  String get limitLabel => 'Limit';
  @override
  String get btnRefreshCommits => 'Refresh commits';
  @override
  String get newestFirst => 'Newest first';
  @override
  String get oldestFirst => 'Oldest first';
  @override
  String get loadingCommitsLong => 'Loading commit history…';
  @override
  String get errCommitPrefix => 'Commits';
  @override
  String get emptyCommits => 'No commits: tap "Refresh commits" / "Sample data", or use paste import below';
  @override
  String get emptySubject => '(empty message)';
  @override
  String get addedWord => 'added';
  @override
  String get removedWord => 'removed';
  @override
  String get fromWord => 'from';
  @override
  String get mergeEdited => '→(edited in merge)';
  @override
  String get newValueFrom => '↑ new value from  ';
  @override
  String get oldFromMerge => 'old value via merge  ';
  @override
  String get oldFrom => 'old value by  ';
  @override
  String get lastSwitch => 'last switch  ';
  @override
  String get newValueUnknown => '↑ new-value source unknown (raise limit & refresh)';
  @override
  String get silentDrop => '⚠ merge silently dropped';
  @override
  String get keptWord => 'kept';
  @override
  String get copied => 'Copied';
  @override
  String get pasteTitle => 'Paste import (all platforms)';
  @override
  String get collapse => 'Collapse';
  @override
  String get expand => 'Expand';
  @override
  String get pasteTagDesc =>
      'Paste `git show-ref -d --tags` output (recommended, includes commits) or `git tag -l` for local; paste `git ls-remote --tags origin` output for remote, to compare any repo. Note: pasted imports carry no commit messages; desktop direct reads attach them automatically (remote needs a fetch first)';
  @override
  String get localPasteLabel => 'Paste local output';
  @override
  String get localPastePlaceholder => 'v1.0.0\nv1.1.0\n… or <sha> refs/tags/v1.0.0';
  @override
  String get parseLocalPaste => 'Parse local paste';
  @override
  String get previewWord => 'preview';
  @override
  String get remotePasteLabel => 'Paste remote output';
  @override
  String get remotePastePlaceholder => '<sha>\trefs/tags/v1.0.0\n<sha>\trefs/tags/v1.0.0^{}';
  @override
  String get parseRemotePaste => 'Parse remote paste';
  @override
  String get pasteCommitDesc => 'Paste commits: run this command in the repo, then paste the output below';
  @override
  String get logCmdBranchHint => '[branch]';
  @override
  String get commitPasteLabel => 'Paste commit output';
  @override
  String get commitPastePlaceholder => '===COMMIT===\nsha: <sha>\n…\n===END===';
  @override
  String get parseCommitPaste => 'Parse commit paste';
  @override
  String get branchPasteLabel => 'Paste branch output (`git branch -a`)';
  @override
  String get branchPastePlaceholder => '* main\n  dev\n  remotes/origin/main';
  @override
  String get parseBranchPaste => 'Parse branch paste';
  @override
  String get submodulePasteLabel => 'Paste submodule output (`git submodule status`)';
  @override
  String get submodulePastePlaceholder => ' 2b699ab… packages/player (main)';
  @override
  String get parseSubmodulePaste => 'Parse submodule paste';
  @override
  String get resolveFail => 'Repo resolve failed';
  @override
  String get unknownError => 'Unknown error';
  @override
  String get cloningToCache => 'Cloning remote repo to cache…';
  @override
  String localTagsOk(int n) => 'Local refresh: $n tags';
  @override
  String clonedTagsOk(int n) => 'Cloned & refreshed: $n tags';
  @override
  String remoteTagsOk(int n) => 'Remote refresh: $n tags';
  @override
  String commitsOk(int n) => 'Commit refresh: $n entries';
  @override
  String clonedCommitsOk(int n) => 'Cloned & refreshed: $n entries';
  @override
  String get commitsParseFail => 'No commits parsed; generate output with the git log command above';
  @override
  String commitsParsedOk(int n) => 'Parsed $n pasted commits';
  @override
  String get branchesParseFail => 'No branches parsed; paste `git branch -a` output';
  @override
  String branchesParsedOk(int n) => 'Parsed $n pasted branches';
  @override
  String get submodulesParseFail => 'No submodules parsed; paste `git submodule status` output';
  @override
  String submodulesParsedOk(int n) => 'Parsed $n pasted submodules';
  @override
  String get tagParseFail => 'No tags parsed; check the format';
  @override
  String localPasteOk(int n) => 'Parsed $n pasted local tags';
  @override
  String remotePasteOk(int n) => 'Parsed $n pasted remote tags';
  @override
  String get sampleLoaded => 'Sample data loaded';
  @override
  String get cleared => 'Cleared';
  @override
  String get localTagsFail => 'Failed to read local tags';
  @override
  String get remoteTagsFail => 'Failed to read remote tags';
  @override
  String get commitsFail => 'Failed to read commits';
  @override
  String get branchesFail => 'Failed to read branches';
  @override
  String get submodulesFail => 'Failed to read submodules';
  @override
  String get remoteUrlFail => 'Failed to read remote URL';
  @override
  String get submoduleBranchFail => 'Failed to read submodule branch';
  @override
  String get dirName => 'dir';
  @override
  String get dirNotExist => 'Directory does not exist';
  @override
  String get gitNotInstalled => 'Cannot run git; make sure it is installed and on PATH';
  @override
  String get gitRunFail => 'Cannot run git';
  @override
  String get updatingCache => 'Updating cached repo…';
  @override
  String get updateStaleCache => 'Update failed, using stale cache';
  @override
  String get cloningCache => 'Cloning to cache…';
  @override
  String get filterFallback => 'Filtered clone failed, retrying full clone…';
  @override
  String get cacheCleanFail => 'Cannot clean cache dir (maybe in use); delete it manually and retry';
  @override
  String get cloneUnusable => 'Cloned repo still unusable; check the URL/permissions and retry';
  @override
  String get cmdLog => 'the git log command above';
  @override
  String get cmdTagLocal => '`git tag` or `git show-ref --tags`';
  @override
  String noNativeGit(String platform, String cmd) =>
      'Cannot run git directly on $platform; use "Paste import" below: paste the output of $cmd, then parse';
  @override
  String platformUnsupported(String platform) => 'Not supported on $platform';
  @override
  String get subUninitialized => 'Uninitialized';
  @override
  String get subModified => 'Modified';
  @override
  String get subConflict => 'Conflict';
}

final AppStrings zhStrings = _ZhStrings();
final AppStrings enStrings = _EnStrings();
