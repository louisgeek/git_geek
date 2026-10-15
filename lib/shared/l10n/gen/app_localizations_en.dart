// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get subtitleDesktop =>
      'Desktop: local dirs or remote URLs (https/ssh) with auto-clone cache';

  @override
  String get subtitleNoGit =>
      'Local git is not supported on this platform; please use the desktop app';

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
  String get repoPathPlaceholder =>
      'D:/code/my-repo or https://github.com/owner/repo.git';

  @override
  String get remoteUrlHint =>
      'Remote URL: auto-clones to local cache on first refresh, then incremental updates';

  @override
  String get cachePrefix => 'Cache';

  @override
  String get copy => 'Copy';

  @override
  String get remoteNameLabel => 'Remote name or URL';

  @override
  String get remoteNamePlaceholder =>
      'origin or https://github.com/owner/repo.git';

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
  String divergedWarn(int count) {
    return 'Warning: $count same-name tags point to different commits; check for accidental tag moves';
  }

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
  String get emptyCompare => 'No data: tap \"Refresh all\" / \"Sample data\"';

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
  String explainOnlyLocal(String tag) {
    return 'Note: local only; run `git push origin $tag` to push';
  }

  @override
  String explainOnlyRemote(String tag) {
    return 'Note: remote only; run `git fetch origin tag $tag` to pull';
  }

  @override
  String get explainDiverged =>
      'Note: same name but different sha; the tag may have been moved, verify before overwriting';

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
  String get emptyCommits =>
      'No commits: tap \"Refresh commits\" / \"Sample data\"';

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
  String get newValueUnknown =>
      '↑ new-value source unknown (raise limit & refresh)';

  @override
  String get silentDrop => '⚠ merge silently dropped';

  @override
  String get keptWord => 'kept';

  @override
  String get copied => 'Copied';

  @override
  String get resolveFail => 'Repo resolve failed';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get cloningToCache => 'Cloning remote repo to cache…';

  @override
  String localTagsOk(int n) {
    return 'Local refresh: $n tags';
  }

  @override
  String remoteTagsOk(int n) {
    return 'Remote refresh: $n tags';
  }

  @override
  String remoteTagsFromCache(int n) {
    return 'Remote read failed; using cached tags: $n';
  }

  @override
  String commitsOk(int n) {
    return 'Commit refresh: $n entries';
  }

  @override
  String clonedCommitsOk(int n) {
    return 'Cloned & refreshed: $n entries';
  }

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
  String get submoduleLogFail => 'Failed to read submodule commits';

  @override
  String get subLogPanelTitle => 'Submodule recent commits';

  @override
  String get subLogPanelEmpty => 'No submodule commits';

  @override
  String get dirName => 'dir';

  @override
  String get dirNotExist => 'Directory does not exist';

  @override
  String get updatingCache => 'Updating cached repo…';

  @override
  String get updateStaleCache => 'Update failed, using stale cache';

  @override
  String get cloningCache => 'Cloning to cache…';

  @override
  String get filterFallback => 'Filtered clone failed, retrying full clone…';

  @override
  String get cacheCleanFail =>
      'Cannot clean cache dir (maybe in use); delete it manually and retry';

  @override
  String get cloneUnusable =>
      'Cloned repo still unusable; check the URL/permissions and retry';

  @override
  String platformUnsupported(String platform) {
    return 'Not supported on $platform';
  }

  @override
  String get subUninitialized => 'Uninitialized';

  @override
  String get subModified => 'Modified';

  @override
  String get subConflict => 'Conflict';

  @override
  String str_app_version_available(String version) {
    return 'Version $version is available';
  }
}
