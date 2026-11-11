// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commits_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Commits 仓储的**契约声明**：只声明类型，不提供默认实现。
///
/// 具体实现由组合根 `app/bootstrap.dart` 用 `overrideWith` 工厂注入。
/// 未 override 就读取会在首次求值时显式抛错。
///
/// 用默认 autoDispose：仓储只持 `final` 依赖、不存可变数据，重建只是
/// 重新绑定引用；串行锁由 `remoteRepoResolverProvider`（keepAlive）持有。

@ProviderFor(commitsRepository)
final commitsRepositoryProvider = CommitsRepositoryProvider._();

/// Commits 仓储的**契约声明**：只声明类型，不提供默认实现。
///
/// 具体实现由组合根 `app/bootstrap.dart` 用 `overrideWith` 工厂注入。
/// 未 override 就读取会在首次求值时显式抛错。
///
/// 用默认 autoDispose：仓储只持 `final` 依赖、不存可变数据，重建只是
/// 重新绑定引用；串行锁由 `remoteRepoResolverProvider`（keepAlive）持有。

final class CommitsRepositoryProvider
    extends
        $FunctionalProvider<
          CommitsRepositoryContract,
          CommitsRepositoryContract,
          CommitsRepositoryContract
        >
    with $Provider<CommitsRepositoryContract> {
  /// Commits 仓储的**契约声明**：只声明类型，不提供默认实现。
  ///
  /// 具体实现由组合根 `app/bootstrap.dart` 用 `overrideWith` 工厂注入。
  /// 未 override 就读取会在首次求值时显式抛错。
  ///
  /// 用默认 autoDispose：仓储只持 `final` 依赖、不存可变数据，重建只是
  /// 重新绑定引用；串行锁由 `remoteRepoResolverProvider`（keepAlive）持有。
  CommitsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commitsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commitsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CommitsRepositoryContract> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommitsRepositoryContract create(Ref ref) {
    return commitsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommitsRepositoryContract value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommitsRepositoryContract>(value),
    );
  }
}

String _$commitsRepositoryHash() => r'7f3677d53a9caa1530122b8e051172b2419be4ec';
