// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 控制器（对标原 GitTagViewModel；Riverpod @riverpod 注解实现）

@ProviderFor(GitTagController)
final gitTagControllerProvider = GitTagControllerProvider._();

/// 控制器（对标原 GitTagViewModel；Riverpod @riverpod 注解实现）
final class GitTagControllerProvider
    extends $NotifierProvider<GitTagController, GitTagUiState> {
  /// 控制器（对标原 GitTagViewModel；Riverpod @riverpod 注解实现）
  GitTagControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gitTagControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gitTagControllerHash();

  @$internal
  @override
  GitTagController create() => GitTagController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GitTagUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GitTagUiState>(value),
    );
  }
}

String _$gitTagControllerHash() => r'7e4e67dab2735b7fca4a2b8f3d07b2dc4dff36da';

/// 控制器（对标原 GitTagViewModel；Riverpod @riverpod 注解实现）

abstract class _$GitTagController extends $Notifier<GitTagUiState> {
  GitTagUiState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GitTagUiState, GitTagUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GitTagUiState, GitTagUiState>,
              GitTagUiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
