// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get subtitleDesktop => '桌面端: 支持本地目录或远程 URL(https/ssh), 自动克隆到缓存';

  @override
  String get subtitleNoGit => '当前平台不支持本地 git，请使用桌面端';

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
  String get repoPathPlaceholder =>
      'D:/code/my-repo  或  https://github.com/owner/repo.git';

  @override
  String get remoteUrlHint => '远程 URL: 首次刷新将自动克隆到本地缓存, 之后增量更新';

  @override
  String get cachePrefix => '缓存';

  @override
  String get copy => '复制';

  @override
  String get remoteNameLabel => '远程名或 URL';

  @override
  String get remoteNamePlaceholder =>
      'origin 或 https://github.com/owner/repo.git';

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
  String divergedWarn(int count) {
    return '注意: 有 $count 个同名 tag 指向不同 commit(不一致),请检查是否误移动 tag';
  }

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
  String get emptyCompare => '暂无数据：点「一键刷新」/「示例数据」';

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
  String explainOnlyLocal(String tag) {
    return '说明: 仅本地存在, 可执行 git push origin $tag 推送';
  }

  @override
  String explainOnlyRemote(String tag) {
    return '说明: 仅远程存在, 可执行 git fetch origin tag $tag 拉取';
  }

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
  String get emptyCommits => '暂无提交：点「刷新提交」/「示例数据」';

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
  String get resolveFail => '仓库解析失败';

  @override
  String get unknownError => '未知错误';

  @override
  String get cloningToCache => '正在克隆远程仓库到缓存…';

  @override
  String localTagsOk(int n) {
    return '本地刷新成功 $n 个';
  }

  @override
  String remoteTagsOk(int n) {
    return '远程刷新成功 $n 个';
  }

  @override
  String remoteTagsFromCache(int n) {
    return '远程读取失败, 已用缓存 tag $n 个';
  }

  @override
  String commitsOk(int n) {
    return '提交记录刷新成功 $n 条';
  }

  @override
  String clonedCommitsOk(int n) {
    return '已克隆并刷新 $n 条';
  }

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
  String get submoduleLogFail => '读取子模块提交失败';

  @override
  String get subLogPanelTitle => '子库最近记录';

  @override
  String get subLogPanelEmpty => '暂无子库记录';

  @override
  String get dirName => '目录';

  @override
  String get dirNotExist => '目录不存在';

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
  String platformUnsupported(String platform) {
    return '$platform 端不支持';
  }

  @override
  String get subUninitialized => '未初始化';

  @override
  String get subModified => '有改动';

  @override
  String get subConflict => '冲突';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get subtitleDesktop => '桌面端: 支援本地目錄或遠端 URL(https/ssh), 自動複製到快取';

  @override
  String get subtitleNoGit => '目前平台不支援本地 git，請使用桌面端';

  @override
  String get about => '關於';

  @override
  String get aboutTitle => '關於 GitGeek';

  @override
  String get aboutVersionLabel => '版本';

  @override
  String get aboutCopyright => '© 2026 GitGeek';

  @override
  String get close => '關閉';

  @override
  String get repoCardTitle => '倉庫設定(任意倉庫)';

  @override
  String get repoPathLabel => '倉庫路徑(本地目錄 或 遠端 URL)';

  @override
  String get repoPathPlaceholder =>
      'D:/code/my-repo  或  https://github.com/owner/repo.git';

  @override
  String get remoteUrlHint => '遠端 URL: 首次重新整理將自動複製到本地快取, 之後增量更新';

  @override
  String get cachePrefix => '快取';

  @override
  String get copy => '複製';

  @override
  String get remoteNameLabel => '遠端名或 URL';

  @override
  String get remoteNamePlaceholder =>
      'origin 或 https://github.com/owner/repo.git';

  @override
  String get scopePrefix => '範圍';

  @override
  String get mainRepo => '主倉庫';

  @override
  String get submoduleWord => '子模組';

  @override
  String get btnRefreshLocal => '重新整理本地';

  @override
  String get btnRefreshRemote => '重新整理遠端';

  @override
  String get btnRefreshAll => '一鍵重新整理';

  @override
  String get btnSample => '範例資料';

  @override
  String get btnClear => '清空';

  @override
  String get cloningFallback => '正在複製遠端倉庫…';

  @override
  String get loadingLocal => '讀取本地中… ';

  @override
  String get loadingRemote => '讀取遠端中…';

  @override
  String get loadingCommits => '讀取提交中… ';

  @override
  String get errLocalPrefix => '本地';

  @override
  String get errRemotePrefix => '遠端';

  @override
  String get errSubmodulePrefix => '子模組';

  @override
  String get statLocal => '本地';

  @override
  String get statRemote => '遠端';

  @override
  String get statSynced => '已同步';

  @override
  String get statOnlyLocal => '僅本地';

  @override
  String get statOnlyRemote => '僅遠端';

  @override
  String get diverged => '不一致';

  @override
  String divergedWarn(int count) {
    return '注意: 有 $count 個同名 tag 指向不同 commit(不一致),請檢查是否誤移動 tag';
  }

  @override
  String get searchTagLabel => '搜尋 tag / sha / 註釋 / 作者';

  @override
  String get sortLabel => '排序';

  @override
  String get sortSemver => '語義版本';

  @override
  String get sortName => '名稱';

  @override
  String get filterAll => '全部';

  @override
  String get tabCompare => '對比總覽';

  @override
  String get tabCommits => '提交記錄';

  @override
  String get emptyCompare => '暫無資料：點「一鍵重新整理」/「範例資料」';

  @override
  String get badgeOnlyLocal => '僅本地·待推送';

  @override
  String get badgeOnlyRemote => '僅遠端·待拉取';

  @override
  String get noSha => '無sha';

  @override
  String get missing => '缺失';

  @override
  String get detailTitle => '詳情';

  @override
  String get missingPushHint => '—(缺失,需推送)';

  @override
  String get missingPullHint => '—(缺失,需拉取)';

  @override
  String get explainSynced => '說明: 兩邊一致,無需操作';

  @override
  String explainOnlyLocal(String tag) {
    return '說明: 僅本地存在, 可執行 git push origin $tag 推送';
  }

  @override
  String explainOnlyRemote(String tag) {
    return '說明: 僅遠端存在, 可執行 git fetch origin tag $tag 拉取';
  }

  @override
  String get explainDiverged => '說明: 同名但 sha 不同, 可能 tag 被移動, 請核對後再決定覆蓋';

  @override
  String get viewCommitBtn => '檢視提交';

  @override
  String get expandHint => '點擊展開詳情';

  @override
  String get annotatedShort => '附註';

  @override
  String get lightweightShort => '輕量';

  @override
  String get pureNameNoSha => 'sha: —(純名稱列表,無 sha)';

  @override
  String get fullSide => '完整';

  @override
  String get tagTypePrefix => '類型';

  @override
  String get annotatedLong => '附註標籤';

  @override
  String get lightweightLong => '輕量標籤';

  @override
  String get tagNotesPrefix => 'tag 註釋';

  @override
  String get emptyLocalTab => '本地暫無 tag';

  @override
  String get emptyRemoteTab => '遠端暫無 tag';

  @override
  String get currentScopePrefix => '目前範圍';

  @override
  String get searchCommitLabel => '搜尋提交 / sha / 作者 / tag';

  @override
  String get currentBranchChip => '目前分支';

  @override
  String get errBranchPrefix => '分支';

  @override
  String get branchLabel => '分支(空=目前)';

  @override
  String get branchPlaceholder => 'main / HEAD / --all';

  @override
  String get limitLabel => '筆數';

  @override
  String get btnRefreshCommits => '重新整理提交';

  @override
  String get newestFirst => '新到舊';

  @override
  String get oldestFirst => '舊到新';

  @override
  String get loadingCommitsLong => '讀取提交記錄中…';

  @override
  String get errCommitPrefix => '提交';

  @override
  String get emptyCommits => '暫無提交：點「重新整理提交」/「範例資料」';

  @override
  String get emptySubject => '(空提交訊息)';

  @override
  String get addedWord => '新增';

  @override
  String get removedWord => '移除';

  @override
  String get fromWord => '從';

  @override
  String get mergeEdited => '→(merge手工改)';

  @override
  String get newValueFrom => '↑ 新值來自  ';

  @override
  String get oldFromMerge => '舊值由 merge 引入  ';

  @override
  String get oldFrom => '舊值由  ';

  @override
  String get lastSwitch => '上次切換  ';

  @override
  String get newValueUnknown => '↑ 新值來源未定位(調大筆數重刷可補)';

  @override
  String get silentDrop => '⚠ merge 靜默丟棄';

  @override
  String get keptWord => '保留了';

  @override
  String get copied => '已複製';

  @override
  String get resolveFail => '倉庫解析失敗';

  @override
  String get unknownError => '未知錯誤';

  @override
  String get cloningToCache => '正在複製遠端倉庫到快取…';

  @override
  String localTagsOk(int n) {
    return '本地重新整理成功 $n 個';
  }

  @override
  String remoteTagsOk(int n) {
    return '遠端重新整理成功 $n 個';
  }

  @override
  String remoteTagsFromCache(int n) {
    return '遠端讀取失敗, 已用快取 tag $n 個';
  }

  @override
  String commitsOk(int n) {
    return '提交記錄重新整理成功 $n 條';
  }

  @override
  String clonedCommitsOk(int n) {
    return '已複製並重新整理 $n 條';
  }

  @override
  String get sampleLoaded => '已載入範例資料';

  @override
  String get cleared => '已清空';

  @override
  String get localTagsFail => '本地 tag 讀取失敗';

  @override
  String get remoteTagsFail => '遠端 tag 讀取失敗';

  @override
  String get commitsFail => '提交記錄讀取失敗';

  @override
  String get branchesFail => '分支列表讀取失敗';

  @override
  String get submodulesFail => '子模組列表讀取失敗';

  @override
  String get remoteUrlFail => '讀取 remote URL 失敗';

  @override
  String get submoduleBranchFail => '讀取子模組分支失敗';

  @override
  String get submoduleLogFail => '讀取子模組提交失敗';

  @override
  String get subLogPanelTitle => '子庫最近記錄';

  @override
  String get subLogPanelEmpty => '暫無子庫記錄';

  @override
  String get dirName => '目錄';

  @override
  String get dirNotExist => '目錄不存在';

  @override
  String get updatingCache => '更新快取倉庫…';

  @override
  String get updateStaleCache => '更新失敗, 使用舊快取';

  @override
  String get cloningCache => '正在複製到快取…';

  @override
  String get filterFallback => '過濾複製失敗, 改用完整複製…';

  @override
  String get cacheCleanFail => '快取目錄無法清理(可能被其他程式佔用), 請手動刪除後重試';

  @override
  String get cloneUnusable => '複製後倉庫仍不可用, 請檢查地址/權限後重試';

  @override
  String platformUnsupported(String platform) {
    return '$platform 端不支援';
  }

  @override
  String get subUninitialized => '未初始化';

  @override
  String get subModified => '有改動';

  @override
  String get subConflict => '衝突';
}

/// The translations for Chinese, as used in Hong Kong, using the Han script (`zh_Hant_HK`).
class AppLocalizationsZhHantHk extends AppLocalizationsZh {
  AppLocalizationsZhHantHk() : super('zh_Hant_HK');

  @override
  String get subtitleDesktop => '桌面端: 支援本地目錄或遠端 URL(https/ssh), 自動複製到快取';

  @override
  String get subtitleNoGit => '目前平台不支援本地 git，請使用桌面端';

  @override
  String get about => '關於';

  @override
  String get aboutTitle => '關於 GitGeek';

  @override
  String get aboutVersionLabel => '版本';

  @override
  String get aboutCopyright => '© 2026 GitGeek';

  @override
  String get close => '關閉';

  @override
  String get repoCardTitle => '倉庫設定(任意倉庫)';

  @override
  String get repoPathLabel => '倉庫路徑(本地目錄 或 遠端 URL)';

  @override
  String get repoPathPlaceholder =>
      'D:/code/my-repo  或  https://github.com/owner/repo.git';

  @override
  String get remoteUrlHint => '遠端 URL: 首次重新載入將自動複製到本地快取, 之後增量更新';

  @override
  String get cachePrefix => '快取';

  @override
  String get copy => '複製';

  @override
  String get remoteNameLabel => '遠端名或 URL';

  @override
  String get remoteNamePlaceholder =>
      'origin 或 https://github.com/owner/repo.git';

  @override
  String get scopePrefix => '範圍';

  @override
  String get mainRepo => '主倉庫';

  @override
  String get submoduleWord => '子模組';

  @override
  String get btnRefreshLocal => '重新載入本地';

  @override
  String get btnRefreshRemote => '重新載入遠端';

  @override
  String get btnRefreshAll => '一鍵重新載入';

  @override
  String get btnSample => '示例資料';

  @override
  String get btnClear => '清空';

  @override
  String get cloningFallback => '正在複製遠端倉庫…';

  @override
  String get loadingLocal => '載入本地中… ';

  @override
  String get loadingRemote => '載入遠端中…';

  @override
  String get loadingCommits => '載入提交中… ';

  @override
  String get errLocalPrefix => '本地';

  @override
  String get errRemotePrefix => '遠端';

  @override
  String get errSubmodulePrefix => '子模組';

  @override
  String get statLocal => '本地';

  @override
  String get statRemote => '遠端';

  @override
  String get statSynced => '已同步';

  @override
  String get statOnlyLocal => '僅本地';

  @override
  String get statOnlyRemote => '僅遠端';

  @override
  String get diverged => '不一致';

  @override
  String divergedWarn(int count) {
    return '注意: 有 $count 個同名 tag 指向不同 commit(不一致),請檢查是否誤移動 tag';
  }

  @override
  String get searchTagLabel => '搜尋 tag / sha / 註釋 / 作者';

  @override
  String get sortLabel => '排序';

  @override
  String get sortSemver => '語義版本';

  @override
  String get sortName => '名稱';

  @override
  String get filterAll => '全部';

  @override
  String get tabCompare => '對比總覽';

  @override
  String get tabCommits => '提交記錄';

  @override
  String get emptyCompare => '暫無資料：按「一鍵重新載入」/「示例資料」';

  @override
  String get badgeOnlyLocal => '僅本地·待推送';

  @override
  String get badgeOnlyRemote => '僅遠端·待提取';

  @override
  String get noSha => '無sha';

  @override
  String get missing => '缺失';

  @override
  String get detailTitle => '詳情';

  @override
  String get missingPushHint => '—(缺失,需推送)';

  @override
  String get missingPullHint => '—(缺失,需提取)';

  @override
  String get explainSynced => '說明: 兩邊一致,無需操作';

  @override
  String explainOnlyLocal(String tag) {
    return '說明: 僅本地存在, 可執行 git push origin $tag 推送';
  }

  @override
  String explainOnlyRemote(String tag) {
    return '說明: 僅遠端存在, 可執行 git fetch origin tag $tag 提取';
  }

  @override
  String get explainDiverged => '說明: 同名但 sha 不同, 可能 tag 被移動, 請核對後再決定覆蓋';

  @override
  String get viewCommitBtn => '查看提交';

  @override
  String get expandHint => '點擊展開詳情';

  @override
  String get annotatedShort => '附註';

  @override
  String get lightweightShort => '輕量';

  @override
  String get pureNameNoSha => 'sha: —(純名稱列表,無 sha)';

  @override
  String get fullSide => '完整';

  @override
  String get tagTypePrefix => '類型';

  @override
  String get annotatedLong => '附註標籤';

  @override
  String get lightweightLong => '輕量標籤';

  @override
  String get tagNotesPrefix => 'tag 註釋';

  @override
  String get emptyLocalTab => '本地暫無 tag';

  @override
  String get emptyRemoteTab => '遠端暫無 tag';

  @override
  String get currentScopePrefix => '目前範圍';

  @override
  String get searchCommitLabel => '搜尋提交 / sha / 作者 / tag';

  @override
  String get currentBranchChip => '目前分支';

  @override
  String get errBranchPrefix => '分支';

  @override
  String get branchLabel => '分支(空=目前)';

  @override
  String get branchPlaceholder => 'main / HEAD / --all';

  @override
  String get limitLabel => '項數';

  @override
  String get btnRefreshCommits => '重新載入提交';

  @override
  String get newestFirst => '新到舊';

  @override
  String get oldestFirst => '舊到新';

  @override
  String get loadingCommitsLong => '載入提交記錄中…';

  @override
  String get errCommitPrefix => '提交';

  @override
  String get emptyCommits => '暫無提交：按「重新載入提交」/「示例資料」';

  @override
  String get emptySubject => '(空提交訊息)';

  @override
  String get addedWord => '新增';

  @override
  String get removedWord => '移除';

  @override
  String get fromWord => '從';

  @override
  String get mergeEdited => '→(merge手工改)';

  @override
  String get newValueFrom => '↑ 新值來自  ';

  @override
  String get oldFromMerge => '舊值由 merge 引入  ';

  @override
  String get oldFrom => '舊值由  ';

  @override
  String get lastSwitch => '上次切換  ';

  @override
  String get newValueUnknown => '↑ 新值來源未定位(調大項數重新載入可補)';

  @override
  String get silentDrop => '⚠ merge 靜默丟棄';

  @override
  String get keptWord => '保留了';

  @override
  String get copied => '已複製';

  @override
  String get resolveFail => '倉庫解析失敗';

  @override
  String get unknownError => '未知錯誤';

  @override
  String get cloningToCache => '正在複製遠端倉庫到快取…';

  @override
  String localTagsOk(int n) {
    return '本地重新載入成功 $n 個';
  }

  @override
  String remoteTagsOk(int n) {
    return '遠端重新載入成功 $n 個';
  }

  @override
  String remoteTagsFromCache(int n) {
    return '遠端讀取失敗, 已用快取 tag $n 個';
  }

  @override
  String commitsOk(int n) {
    return '提交記錄重新載入成功 $n 項';
  }

  @override
  String clonedCommitsOk(int n) {
    return '已複製並重新載入 $n 項';
  }

  @override
  String get sampleLoaded => '已載入示例資料';

  @override
  String get cleared => '已清空';

  @override
  String get localTagsFail => '本地 tag 載入失敗';

  @override
  String get remoteTagsFail => '遠端 tag 載入失敗';

  @override
  String get commitsFail => '提交記錄載入失敗';

  @override
  String get branchesFail => '分支列表載入失敗';

  @override
  String get submodulesFail => '子模組列表載入失敗';

  @override
  String get remoteUrlFail => '載入 remote URL 失敗';

  @override
  String get submoduleBranchFail => '載入子模組分支失敗';

  @override
  String get submoduleLogFail => '載入子模組提交失敗';

  @override
  String get subLogPanelTitle => '子庫最近記錄';

  @override
  String get subLogPanelEmpty => '暫無子庫記錄';

  @override
  String get dirName => '目錄';

  @override
  String get dirNotExist => '目錄不存在';

  @override
  String get updatingCache => '更新快取倉庫…';

  @override
  String get updateStaleCache => '更新失敗, 使用舊快取';

  @override
  String get cloningCache => '正在複製到快取…';

  @override
  String get filterFallback => '過濾複製失敗, 改用完整複製…';

  @override
  String get cacheCleanFail => '快取目錄無法清理(可能被其他程式佔用), 請手動刪除後重試';

  @override
  String get cloneUnusable => '複製後倉庫仍不可用, 請檢查位址/權限後重試';

  @override
  String platformUnsupported(String platform) {
    return '$platform 端不支援';
  }

  @override
  String get subUninitialized => '未初始化';

  @override
  String get subModified => '有改動';

  @override
  String get subConflict => '衝突';
}
