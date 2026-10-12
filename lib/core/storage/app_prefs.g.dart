// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_prefs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SharedPreferences 实例：main() 里预加载后 override，业务只读 provider。
/// 与消费者 SettingsRepository 同文件，避免 core→di 反向引用；
/// 普通偏好放这里；token/密码放 TokenStore；离线表结构数据放 Sembast。

@ProviderFor(appPrefs)
final appPrefsProvider = AppPrefsProvider._();

/// SharedPreferences 实例：main() 里预加载后 override，业务只读 provider。
/// 与消费者 SettingsRepository 同文件，避免 core→di 反向引用；
/// 普通偏好放这里；token/密码放 TokenStore；离线表结构数据放 Sembast。

final class AppPrefsProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// SharedPreferences 实例：main() 里预加载后 override，业务只读 provider。
  /// 与消费者 SettingsRepository 同文件，避免 core→di 反向引用；
  /// 普通偏好放这里；token/密码放 TokenStore；离线表结构数据放 Sembast。
  AppPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appPrefsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appPrefsHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return appPrefs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$appPrefsHash() => r'a59700ea41e8ee64793129da9b497246e8966a1c';

/// 强类型偏好读写：key 与旧 GitTagSettings 保持一致，保证老数据可迁移。
/// 有状态 Notifier，留在 core。

@ProviderFor(SettingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// 强类型偏好读写：key 与旧 GitTagSettings 保持一致，保证老数据可迁移。
/// 有状态 Notifier，留在 core。
final class SettingsRepositoryProvider
    extends $NotifierProvider<SettingsRepository, SettingsState> {
  /// 强类型偏好读写：key 与旧 GitTagSettings 保持一致，保证老数据可迁移。
  /// 有状态 Notifier，留在 core。
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  SettingsRepository create() => SettingsRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsState>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'52d11a73e8ac3d9738c2f6a9c5295f0cc3892b5b';

/// 强类型偏好读写：key 与旧 GitTagSettings 保持一致，保证老数据可迁移。
/// 有状态 Notifier，留在 core。

abstract class _$SettingsRepository extends $Notifier<SettingsState> {
  SettingsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SettingsState, SettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SettingsState, SettingsState>,
              SettingsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
