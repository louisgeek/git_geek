// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tags 仓储的**契约声明**：只声明类型，不提供默认实现。
///
/// 具体实现由组合根 `app/bootstrap.dart` 用 `overrideWith` 工厂注入
/// （`ProviderScope.overrides`）。未 override 就读取会在首次求值时显式抛错，
/// 不会静默造出第二个实现实例。
///
/// 用默认 autoDispose：仓储只持 `final` 依赖、不存可变数据，重建只是
/// 重新绑定引用；缓存与串行锁由它依赖的组件持有（`appDatabaseProvider`、
/// `remoteRepoResolverProvider` 各自 keepAlive）。

@ProviderFor(tagsRepository)
final tagsRepositoryProvider = TagsRepositoryProvider._();

/// Tags 仓储的**契约声明**：只声明类型，不提供默认实现。
///
/// 具体实现由组合根 `app/bootstrap.dart` 用 `overrideWith` 工厂注入
/// （`ProviderScope.overrides`）。未 override 就读取会在首次求值时显式抛错，
/// 不会静默造出第二个实现实例。
///
/// 用默认 autoDispose：仓储只持 `final` 依赖、不存可变数据，重建只是
/// 重新绑定引用；缓存与串行锁由它依赖的组件持有（`appDatabaseProvider`、
/// `remoteRepoResolverProvider` 各自 keepAlive）。

final class TagsRepositoryProvider
    extends
        $FunctionalProvider<
          TagsRepositoryContract,
          TagsRepositoryContract,
          TagsRepositoryContract
        >
    with $Provider<TagsRepositoryContract> {
  /// Tags 仓储的**契约声明**：只声明类型，不提供默认实现。
  ///
  /// 具体实现由组合根 `app/bootstrap.dart` 用 `overrideWith` 工厂注入
  /// （`ProviderScope.overrides`）。未 override 就读取会在首次求值时显式抛错，
  /// 不会静默造出第二个实现实例。
  ///
  /// 用默认 autoDispose：仓储只持 `final` 依赖、不存可变数据，重建只是
  /// 重新绑定引用；缓存与串行锁由它依赖的组件持有（`appDatabaseProvider`、
  /// `remoteRepoResolverProvider` 各自 keepAlive）。
  TagsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagsRepositoryHash();

  @$internal
  @override
  $ProviderElement<TagsRepositoryContract> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TagsRepositoryContract create(Ref ref) {
    return tagsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagsRepositoryContract value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagsRepositoryContract>(value),
    );
  }
}

String _$tagsRepositoryHash() => r'b1f36ef81dd512e7b8d85a81a3d296ce41cda59f';
