// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 强类型偏好读写：key 与旧 GitTagSettings 保持一致，保证老数据可迁移。
///
/// 虽然放在 core/storage（与存储设施同目录便于发现），但它是**有业务语义**
/// 的状态持有者：key 名、默认值都是 GitGeek 的业务约定。因此只允许
/// features/ 下的消费者读取，不放 shared、不被 core 内其他代码依赖。

@ProviderFor(SettingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// 强类型偏好读写：key 与旧 GitTagSettings 保持一致，保证老数据可迁移。
///
/// 虽然放在 core/storage（与存储设施同目录便于发现），但它是**有业务语义**
/// 的状态持有者：key 名、默认值都是 GitGeek 的业务约定。因此只允许
/// features/ 下的消费者读取，不放 shared、不被 core 内其他代码依赖。
final class SettingsRepositoryProvider
    extends $NotifierProvider<SettingsRepository, SettingsState> {
  /// 强类型偏好读写：key 与旧 GitTagSettings 保持一致，保证老数据可迁移。
  ///
  /// 虽然放在 core/storage（与存储设施同目录便于发现），但它是**有业务语义**
  /// 的状态持有者：key 名、默认值都是 GitGeek 的业务约定。因此只允许
  /// features/ 下的消费者读取，不放 shared、不被 core 内其他代码依赖。
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
///
/// 虽然放在 core/storage（与存储设施同目录便于发现），但它是**有业务语义**
/// 的状态持有者：key 名、默认值都是 GitGeek 的业务约定。因此只允许
/// features/ 下的消费者读取，不放 shared、不被 core 内其他代码依赖。

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
