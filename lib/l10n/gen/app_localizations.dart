import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale.fromSubtags(
      languageCode: 'zh',
      countryCode: 'HK',
      scriptCode: 'Hant',
    ),
  ];

  /// No description provided for @subtitleDesktop.
  ///
  /// In en, this message translates to:
  /// **'Desktop: local dirs or remote URLs (https/ssh) with auto-clone cache'**
  String get subtitleDesktop;

  /// No description provided for @subtitleNoGit.
  ///
  /// In en, this message translates to:
  /// **'Local git is not supported on this platform; please use the desktop app'**
  String get subtitleNoGit;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About GitGeek'**
  String get aboutTitle;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersionLabel;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 GitGeek'**
  String get aboutCopyright;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @repoCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Repository (any repo)'**
  String get repoCardTitle;

  /// No description provided for @repoPathLabel.
  ///
  /// In en, this message translates to:
  /// **'Repo path (local dir or remote URL)'**
  String get repoPathLabel;

  /// No description provided for @repoPathPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'D:/code/my-repo or https://github.com/owner/repo.git'**
  String get repoPathPlaceholder;

  /// No description provided for @remoteUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Remote URL: auto-clones to local cache on first refresh, then incremental updates'**
  String get remoteUrlHint;

  /// No description provided for @cachePrefix.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cachePrefix;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @remoteNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Remote name or URL'**
  String get remoteNameLabel;

  /// No description provided for @remoteNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'origin or https://github.com/owner/repo.git'**
  String get remoteNamePlaceholder;

  /// No description provided for @scopePrefix.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get scopePrefix;

  /// No description provided for @mainRepo.
  ///
  /// In en, this message translates to:
  /// **'Main repo'**
  String get mainRepo;

  /// No description provided for @submoduleWord.
  ///
  /// In en, this message translates to:
  /// **'Submodule'**
  String get submoduleWord;

  /// No description provided for @btnRefreshLocal.
  ///
  /// In en, this message translates to:
  /// **'Refresh local'**
  String get btnRefreshLocal;

  /// No description provided for @btnRefreshRemote.
  ///
  /// In en, this message translates to:
  /// **'Refresh remote'**
  String get btnRefreshRemote;

  /// No description provided for @btnRefreshAll.
  ///
  /// In en, this message translates to:
  /// **'Refresh all'**
  String get btnRefreshAll;

  /// No description provided for @btnSample.
  ///
  /// In en, this message translates to:
  /// **'Sample data'**
  String get btnSample;

  /// No description provided for @btnClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get btnClear;

  /// No description provided for @cloningFallback.
  ///
  /// In en, this message translates to:
  /// **'Cloning remote repo…'**
  String get cloningFallback;

  /// No description provided for @loadingLocal.
  ///
  /// In en, this message translates to:
  /// **'Loading local… '**
  String get loadingLocal;

  /// No description provided for @loadingRemote.
  ///
  /// In en, this message translates to:
  /// **'Loading remote…'**
  String get loadingRemote;

  /// No description provided for @loadingCommits.
  ///
  /// In en, this message translates to:
  /// **'Loading commits… '**
  String get loadingCommits;

  /// No description provided for @errLocalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get errLocalPrefix;

  /// No description provided for @errRemotePrefix.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get errRemotePrefix;

  /// No description provided for @errSubmodulePrefix.
  ///
  /// In en, this message translates to:
  /// **'Submodule'**
  String get errSubmodulePrefix;

  /// No description provided for @statLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get statLocal;

  /// No description provided for @statRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get statRemote;

  /// No description provided for @statSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get statSynced;

  /// No description provided for @statOnlyLocal.
  ///
  /// In en, this message translates to:
  /// **'Local only'**
  String get statOnlyLocal;

  /// No description provided for @statOnlyRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote only'**
  String get statOnlyRemote;

  /// No description provided for @diverged.
  ///
  /// In en, this message translates to:
  /// **'Diverged'**
  String get diverged;

  /// No description provided for @divergedWarn.
  ///
  /// In en, this message translates to:
  /// **'Warning: {count} same-name tags point to different commits; check for accidental tag moves'**
  String divergedWarn(int count);

  /// No description provided for @searchTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Search tags / sha / message / author'**
  String get searchTagLabel;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @sortSemver.
  ///
  /// In en, this message translates to:
  /// **'SemVer'**
  String get sortSemver;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @tabCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get tabCompare;

  /// No description provided for @tabCommits.
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get tabCommits;

  /// No description provided for @emptyCompare.
  ///
  /// In en, this message translates to:
  /// **'No data: tap \"Refresh all\" / \"Sample data\"'**
  String get emptyCompare;

  /// No description provided for @badgeOnlyLocal.
  ///
  /// In en, this message translates to:
  /// **'Local only · to push'**
  String get badgeOnlyLocal;

  /// No description provided for @badgeOnlyRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote only · to pull'**
  String get badgeOnlyRemote;

  /// No description provided for @noSha.
  ///
  /// In en, this message translates to:
  /// **'no sha'**
  String get noSha;

  /// No description provided for @missing.
  ///
  /// In en, this message translates to:
  /// **'missing'**
  String get missing;

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailTitle;

  /// No description provided for @missingPushHint.
  ///
  /// In en, this message translates to:
  /// **'—(missing, needs push)'**
  String get missingPushHint;

  /// No description provided for @missingPullHint.
  ///
  /// In en, this message translates to:
  /// **'—(missing, needs pull)'**
  String get missingPullHint;

  /// No description provided for @explainSynced.
  ///
  /// In en, this message translates to:
  /// **'Note: both sides match, nothing to do'**
  String get explainSynced;

  /// No description provided for @explainOnlyLocal.
  ///
  /// In en, this message translates to:
  /// **'Note: local only; run `git push origin {tag}` to push'**
  String explainOnlyLocal(String tag);

  /// No description provided for @explainOnlyRemote.
  ///
  /// In en, this message translates to:
  /// **'Note: remote only; run `git fetch origin tag {tag}` to pull'**
  String explainOnlyRemote(String tag);

  /// No description provided for @explainDiverged.
  ///
  /// In en, this message translates to:
  /// **'Note: same name but different sha; the tag may have been moved, verify before overwriting'**
  String get explainDiverged;

  /// No description provided for @viewCommitBtn.
  ///
  /// In en, this message translates to:
  /// **'View commits'**
  String get viewCommitBtn;

  /// No description provided for @expandHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to expand'**
  String get expandHint;

  /// No description provided for @annotatedShort.
  ///
  /// In en, this message translates to:
  /// **'Annotated'**
  String get annotatedShort;

  /// No description provided for @lightweightShort.
  ///
  /// In en, this message translates to:
  /// **'Lightweight'**
  String get lightweightShort;

  /// No description provided for @pureNameNoSha.
  ///
  /// In en, this message translates to:
  /// **'sha: —(name-only list, no sha)'**
  String get pureNameNoSha;

  /// No description provided for @fullSide.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get fullSide;

  /// No description provided for @tagTypePrefix.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get tagTypePrefix;

  /// No description provided for @annotatedLong.
  ///
  /// In en, this message translates to:
  /// **'Annotated tag'**
  String get annotatedLong;

  /// No description provided for @lightweightLong.
  ///
  /// In en, this message translates to:
  /// **'Lightweight tag'**
  String get lightweightLong;

  /// No description provided for @tagNotesPrefix.
  ///
  /// In en, this message translates to:
  /// **'tag notes'**
  String get tagNotesPrefix;

  /// No description provided for @emptyLocalTab.
  ///
  /// In en, this message translates to:
  /// **'No local tags'**
  String get emptyLocalTab;

  /// No description provided for @emptyRemoteTab.
  ///
  /// In en, this message translates to:
  /// **'No remote tags'**
  String get emptyRemoteTab;

  /// No description provided for @currentScopePrefix.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get currentScopePrefix;

  /// No description provided for @searchCommitLabel.
  ///
  /// In en, this message translates to:
  /// **'Search commits / sha / author / tag'**
  String get searchCommitLabel;

  /// No description provided for @currentBranchChip.
  ///
  /// In en, this message translates to:
  /// **'Current branch'**
  String get currentBranchChip;

  /// No description provided for @errBranchPrefix.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get errBranchPrefix;

  /// No description provided for @branchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch (empty=current)'**
  String get branchLabel;

  /// No description provided for @branchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'main / HEAD / --all'**
  String get branchPlaceholder;

  /// No description provided for @limitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limitLabel;

  /// No description provided for @btnRefreshCommits.
  ///
  /// In en, this message translates to:
  /// **'Refresh commits'**
  String get btnRefreshCommits;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldestFirst;

  /// No description provided for @loadingCommitsLong.
  ///
  /// In en, this message translates to:
  /// **'Loading commit history…'**
  String get loadingCommitsLong;

  /// No description provided for @errCommitPrefix.
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get errCommitPrefix;

  /// No description provided for @emptyCommits.
  ///
  /// In en, this message translates to:
  /// **'No commits: tap \"Refresh commits\" / \"Sample data\"'**
  String get emptyCommits;

  /// No description provided for @emptySubject.
  ///
  /// In en, this message translates to:
  /// **'(empty message)'**
  String get emptySubject;

  /// No description provided for @addedWord.
  ///
  /// In en, this message translates to:
  /// **'added'**
  String get addedWord;

  /// No description provided for @removedWord.
  ///
  /// In en, this message translates to:
  /// **'removed'**
  String get removedWord;

  /// No description provided for @fromWord.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get fromWord;

  /// No description provided for @mergeEdited.
  ///
  /// In en, this message translates to:
  /// **'→(edited in merge)'**
  String get mergeEdited;

  /// No description provided for @newValueFrom.
  ///
  /// In en, this message translates to:
  /// **'↑ new value from  '**
  String get newValueFrom;

  /// No description provided for @oldFromMerge.
  ///
  /// In en, this message translates to:
  /// **'old value via merge  '**
  String get oldFromMerge;

  /// No description provided for @oldFrom.
  ///
  /// In en, this message translates to:
  /// **'old value by  '**
  String get oldFrom;

  /// No description provided for @lastSwitch.
  ///
  /// In en, this message translates to:
  /// **'last switch  '**
  String get lastSwitch;

  /// No description provided for @newValueUnknown.
  ///
  /// In en, this message translates to:
  /// **'↑ new-value source unknown (raise limit & refresh)'**
  String get newValueUnknown;

  /// No description provided for @silentDrop.
  ///
  /// In en, this message translates to:
  /// **'⚠ merge silently dropped'**
  String get silentDrop;

  /// No description provided for @keptWord.
  ///
  /// In en, this message translates to:
  /// **'kept'**
  String get keptWord;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @resolveFail.
  ///
  /// In en, this message translates to:
  /// **'Repo resolve failed'**
  String get resolveFail;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @cloningToCache.
  ///
  /// In en, this message translates to:
  /// **'Cloning remote repo to cache…'**
  String get cloningToCache;

  /// No description provided for @localTagsOk.
  ///
  /// In en, this message translates to:
  /// **'Local refresh: {n} tags'**
  String localTagsOk(int n);

  /// No description provided for @remoteTagsOk.
  ///
  /// In en, this message translates to:
  /// **'Remote refresh: {n} tags'**
  String remoteTagsOk(int n);

  /// No description provided for @remoteTagsFromCache.
  ///
  /// In en, this message translates to:
  /// **'Remote read failed; using cached tags: {n}'**
  String remoteTagsFromCache(int n);

  /// No description provided for @commitsOk.
  ///
  /// In en, this message translates to:
  /// **'Commit refresh: {n} entries'**
  String commitsOk(int n);

  /// No description provided for @clonedCommitsOk.
  ///
  /// In en, this message translates to:
  /// **'Cloned & refreshed: {n} entries'**
  String clonedCommitsOk(int n);

  /// No description provided for @sampleLoaded.
  ///
  /// In en, this message translates to:
  /// **'Sample data loaded'**
  String get sampleLoaded;

  /// No description provided for @cleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get cleared;

  /// No description provided for @localTagsFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to read local tags'**
  String get localTagsFail;

  /// No description provided for @remoteTagsFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to read remote tags'**
  String get remoteTagsFail;

  /// No description provided for @commitsFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to read commits'**
  String get commitsFail;

  /// No description provided for @branchesFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to read branches'**
  String get branchesFail;

  /// No description provided for @submodulesFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to read submodules'**
  String get submodulesFail;

  /// No description provided for @remoteUrlFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to read remote URL'**
  String get remoteUrlFail;

  /// No description provided for @submoduleBranchFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to read submodule branch'**
  String get submoduleBranchFail;

  /// No description provided for @submoduleLogFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to read submodule commits'**
  String get submoduleLogFail;

  /// No description provided for @subLogPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Submodule recent commits'**
  String get subLogPanelTitle;

  /// No description provided for @subLogPanelEmpty.
  ///
  /// In en, this message translates to:
  /// **'No submodule commits'**
  String get subLogPanelEmpty;

  /// No description provided for @dirName.
  ///
  /// In en, this message translates to:
  /// **'dir'**
  String get dirName;

  /// No description provided for @dirNotExist.
  ///
  /// In en, this message translates to:
  /// **'Directory does not exist'**
  String get dirNotExist;

  /// No description provided for @updatingCache.
  ///
  /// In en, this message translates to:
  /// **'Updating cached repo…'**
  String get updatingCache;

  /// No description provided for @updateStaleCache.
  ///
  /// In en, this message translates to:
  /// **'Update failed, using stale cache'**
  String get updateStaleCache;

  /// No description provided for @cloningCache.
  ///
  /// In en, this message translates to:
  /// **'Cloning to cache…'**
  String get cloningCache;

  /// No description provided for @filterFallback.
  ///
  /// In en, this message translates to:
  /// **'Filtered clone failed, retrying full clone…'**
  String get filterFallback;

  /// No description provided for @cacheCleanFail.
  ///
  /// In en, this message translates to:
  /// **'Cannot clean cache dir (maybe in use); delete it manually and retry'**
  String get cacheCleanFail;

  /// No description provided for @cloneUnusable.
  ///
  /// In en, this message translates to:
  /// **'Cloned repo still unusable; check the URL/permissions and retry'**
  String get cloneUnusable;

  /// No description provided for @platformUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Not supported on {platform}'**
  String platformUnsupported(String platform);

  /// No description provided for @subUninitialized.
  ///
  /// In en, this message translates to:
  /// **'Uninitialized'**
  String get subUninitialized;

  /// No description provided for @subModified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get subModified;

  /// No description provided for @subConflict.
  ///
  /// In en, this message translates to:
  /// **'Conflict'**
  String get subConflict;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script+country codes are specified.
  switch (locale.toString()) {
    case 'zh_Hant_HK':
      return AppLocalizationsZhHantHk();
  }

  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
