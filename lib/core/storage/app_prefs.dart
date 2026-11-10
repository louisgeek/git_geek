import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_prefs.freezed.dart';
part 'app_prefs.g.dart';

/// SharedPreferences 实例：main() 里预加载后 override，业务只读 provider。
/// 与消费者 SettingsRepository 同文件，避免 core→di 反向引用；
/// 普通偏好放这里；token/密码放 TokenStore；离线表结构数据放 Sembast。
@Riverpod(keepAlive: true)
SharedPreferences appPrefs(Ref ref) => throw UnimplementedError(
      'appPrefsProvider must be overridden in main() with loaded instance',
    );

/// 强类型偏好读写：key 与旧 GitTagSettings 保持一致，保证老数据可迁移。
/// 有状态 Notifier，留在 core。
@Riverpod(keepAlive: true)
class SettingsRepository extends _$SettingsRepository {
  static const kRepoPath = 'gitgeek.repoPath';
  static const kRemote = 'gitgeek.remote';
  static const kLang = 'gitgeek.lang';
  static const kSortMode = 'gitgeek.sortMode';
  static const kBranch = 'gitgeek.branch';

  /// 从 SharedPreferences 构建初始偏好快照。
  @override
  SettingsState build() {
    final prefs = ref.watch(appPrefsProvider);
    return SettingsState(
      repoPath: prefs.getString(kRepoPath) ?? '',
      remote: prefs.getString(kRemote) ?? 'origin',
      langCode: prefs.getString(kLang) ?? 'zh',
      sortModeName: prefs.getString(kSortMode) ?? 'semverDesc',
      branch: prefs.getString(kBranch) ?? '',
    );
  }

  Future<void> setRepoPath(String v) async {
    await ref.read(appPrefsProvider).setString(kRepoPath, v);
    state = state.copyWith(repoPath: v);
  }

  Future<void> setRemote(String v) async {
    await ref.read(appPrefsProvider).setString(kRemote, v);
    state = state.copyWith(remote: v);
  }

  Future<void> setLang(String code) async {
    await ref.read(appPrefsProvider).setString(kLang, code);
    state = state.copyWith(langCode: code);
  }

  Future<void> setSortMode(String name) async {
    await ref.read(appPrefsProvider).setString(kSortMode, name);
    state = state.copyWith(sortModeName: name);
  }

  Future<void> setBranch(String v) async {
    await ref.read(appPrefsProvider).setString(kBranch, v);
    state = state.copyWith(branch: v);
  }
}

/// 偏好快照：仓库路径、远端、语言、排序、分支。
@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default('') String repoPath,
    @Default('origin') String remote,
    @Default('zh') String langCode,
    @Default('semverDesc') String sortModeName,
    @Default('') String branch,
  }) = _SettingsState;
}
