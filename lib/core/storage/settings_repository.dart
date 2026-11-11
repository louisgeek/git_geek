import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:git_geek/core/storage/app_prefs.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_repository.freezed.dart';
part 'settings_repository.g.dart';

/// 强类型偏好读写：key 与旧 GitTagSettings 保持一致，保证老数据可迁移。
///
/// 虽然放在 core/storage（与存储设施同目录便于发现），但它是**有业务语义**
/// 的状态持有者：key 名、默认值都是 GitGeek 的业务约定。因此只允许
/// features/ 下的消费者读取，不放 shared、不被 core 内其他代码依赖。
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
