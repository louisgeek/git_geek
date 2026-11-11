// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 应用外壳协调器（原 GitTagController）：持有仓库配置 + tab/范围，
/// tags 数据在 TagsNotifier，commits/branches/submodules 在 CommitsNotifier，
/// 这里只做转发、跨 tab 导航与示例数据。

@ProviderFor(WorkspaceNotifier)
final workspaceProvider = WorkspaceNotifierProvider._();

/// 应用外壳协调器（原 GitTagController）：持有仓库配置 + tab/范围，
/// tags 数据在 TagsNotifier，commits/branches/submodules 在 CommitsNotifier，
/// 这里只做转发、跨 tab 导航与示例数据。
final class WorkspaceNotifierProvider
    extends $NotifierProvider<WorkspaceNotifier, WorkspaceState> {
  /// 应用外壳协调器（原 GitTagController）：持有仓库配置 + tab/范围，
  /// tags 数据在 TagsNotifier，commits/branches/submodules 在 CommitsNotifier，
  /// 这里只做转发、跨 tab 导航与示例数据。
  WorkspaceNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspaceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspaceNotifierHash();

  @$internal
  @override
  WorkspaceNotifier create() => WorkspaceNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkspaceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkspaceState>(value),
    );
  }
}

String _$workspaceNotifierHash() => r'3157d781cb525830425d885de87acb4a66211e09';

/// 应用外壳协调器（原 GitTagController）：持有仓库配置 + tab/范围，
/// tags 数据在 TagsNotifier，commits/branches/submodules 在 CommitsNotifier，
/// 这里只做转发、跨 tab 导航与示例数据。

abstract class _$WorkspaceNotifier extends $Notifier<WorkspaceState> {
  WorkspaceState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WorkspaceState, WorkspaceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkspaceState, WorkspaceState>,
              WorkspaceState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
