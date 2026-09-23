// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// tags feature 装配（薄封装，autoDispose 即可）。

@ProviderFor(tagsRepository)
final tagsRepositoryProvider = TagsRepositoryProvider._();

/// tags feature 装配（薄封装，autoDispose 即可）。

final class TagsRepositoryProvider
    extends $FunctionalProvider<TagsRepository, TagsRepository, TagsRepository>
    with $Provider<TagsRepository> {
  /// tags feature 装配（薄封装，autoDispose 即可）。
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
  $ProviderElement<TagsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TagsRepository create(Ref ref) {
    return tagsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagsRepository>(value),
    );
  }
}

String _$tagsRepositoryHash() => r'decde0c9ea7ba6c503fce683a4b6db8a6a5454f4';
