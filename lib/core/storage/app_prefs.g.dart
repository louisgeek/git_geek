// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_prefs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SharedPreferences 实例（core 基础设施）。
///
/// 启动期由组合根 `app/bootstrap.dart` 预加载后 override；
/// 业务只经此 provider 读取原始偏好，读写语义见 `settings_repository.dart`。
/// 普通偏好放这里；token/密码放 TokenStore；离线表结构数据放 Sembast。

@ProviderFor(appPrefs)
final appPrefsProvider = AppPrefsProvider._();

/// SharedPreferences 实例（core 基础设施）。
///
/// 启动期由组合根 `app/bootstrap.dart` 预加载后 override；
/// 业务只经此 provider 读取原始偏好，读写语义见 `settings_repository.dart`。
/// 普通偏好放这里；token/密码放 TokenStore；离线表结构数据放 Sembast。

final class AppPrefsProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// SharedPreferences 实例（core 基础设施）。
  ///
  /// 启动期由组合根 `app/bootstrap.dart` 预加载后 override；
  /// 业务只经此 provider 读取原始偏好，读写语义见 `settings_repository.dart`。
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

String _$appPrefsHash() => r'12cd762d8139f77121ffccb43346736db10e6423';
