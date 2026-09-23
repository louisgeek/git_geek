import 'package:git_geek/di/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_prefs.g.dart';

/// 强类型偏好读写：key 与旧 GitTagSettings 保持一致，保证老数据可迁移。
/// 有状态 Notifier，留在 core；无状态的 appPrefsProvider 装配见 di/storage.dart。
@Riverpod(keepAlive: true)
class SettingsRepository extends _$SettingsRepository {
  static const kRepoPath = 'gitgeek.repoPath';
  static const kRemote = 'gitgeek.remote';
  static const kLang = 'gitgeek.lang';
  static const kSortMode = 'gitgeek.sortMode';
  static const kBranch = 'gitgeek.branch';

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

class SettingsState {
  final String repoPath;
  final String remote;
  final String langCode;
  final String sortModeName;
  final String branch;

  const SettingsState({
    this.repoPath = '',
    this.remote = 'origin',
    this.langCode = 'zh',
    this.sortModeName = 'semverDesc',
    this.branch = '',
  });

  SettingsState copyWith({
    String? repoPath,
    String? remote,
    String? langCode,
    String? sortModeName,
    String? branch,
  }) {
    return SettingsState(
      repoPath: repoPath ?? this.repoPath,
      remote: remote ?? this.remote,
      langCode: langCode ?? this.langCode,
      sortModeName: sortModeName ?? this.sortModeName,
      branch: branch ?? this.branch,
    );
  }
}
