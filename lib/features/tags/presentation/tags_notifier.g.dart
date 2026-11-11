// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tags 子 Notifier（新架构）：唯一持有 local/remote tags + 查询/排序/过滤。
/// 远程读取失败时读本地缓存兜底（[TagsState.remoteFromCache]）。
/// 装配见 `features/tags/tags_providers.dart`（组合根注入实现）。

@ProviderFor(TagsNotifier)
final tagsProvider = TagsNotifierProvider._();

/// Tags 子 Notifier（新架构）：唯一持有 local/remote tags + 查询/排序/过滤。
/// 远程读取失败时读本地缓存兜底（[TagsState.remoteFromCache]）。
/// 装配见 `features/tags/tags_providers.dart`（组合根注入实现）。
final class TagsNotifierProvider
    extends $NotifierProvider<TagsNotifier, TagsState> {
  /// Tags 子 Notifier（新架构）：唯一持有 local/remote tags + 查询/排序/过滤。
  /// 远程读取失败时读本地缓存兜底（[TagsState.remoteFromCache]）。
  /// 装配见 `features/tags/tags_providers.dart`（组合根注入实现）。
  TagsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagsNotifierHash();

  @$internal
  @override
  TagsNotifier create() => TagsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagsState>(value),
    );
  }
}

String _$tagsNotifierHash() => r'105d7b2d82ef58a4fbec06cf8eac05031fb0f2e2';

/// Tags 子 Notifier（新架构）：唯一持有 local/remote tags + 查询/排序/过滤。
/// 远程读取失败时读本地缓存兜底（[TagsState.remoteFromCache]）。
/// 装配见 `features/tags/tags_providers.dart`（组合根注入实现）。

abstract class _$TagsNotifier extends $Notifier<TagsState> {
  TagsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TagsState, TagsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TagsState, TagsState>,
              TagsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
