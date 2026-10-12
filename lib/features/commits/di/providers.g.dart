// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// commits feature 装配（薄封装，autoDispose 即可）。

@ProviderFor(commitsRepository)
final commitsRepositoryProvider = CommitsRepositoryProvider._();

/// commits feature 装配（薄封装，autoDispose 即可）。

final class CommitsRepositoryProvider
    extends
        $FunctionalProvider<
          CommitsRepository,
          CommitsRepository,
          CommitsRepository
        >
    with $Provider<CommitsRepository> {
  /// commits feature 装配（薄封装，autoDispose 即可）。
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
  $ProviderElement<CommitsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommitsRepository create(Ref ref) {
    return commitsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommitsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommitsRepository>(value),
    );
  }
}

String _$commitsRepositoryHash() => r'f20acf8d3057118bb1dd02e7dc2f696b4d3993be';
