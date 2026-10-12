// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Dio 装配：只负责 GitHub/GitLab 等 HTTP API，不替代本地 git CLI。
/// 本地 git 操作走 `lib/di/git.dart` 的 gitRunnerProvider（Process）。

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// Dio 装配：只负责 GitHub/GitLab 等 HTTP API，不替代本地 git CLI。
/// 本地 git 操作走 `lib/di/git.dart` 的 gitRunnerProvider（Process）。

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Dio 装配：只负责 GitHub/GitLab 等 HTTP API，不替代本地 git CLI。
  /// 本地 git 操作走 `lib/di/git.dart` 的 gitRunnerProvider（Process）。
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'36ca932e87795b4bd95efd4b9413194e120b320f';

/// GitHub API 装配：基于共享 Dio 实例。

@ProviderFor(githubApi)
final githubApiProvider = GithubApiProvider._();

/// GitHub API 装配：基于共享 Dio 实例。

final class GithubApiProvider
    extends $FunctionalProvider<GithubApi, GithubApi, GithubApi>
    with $Provider<GithubApi> {
  /// GitHub API 装配：基于共享 Dio 实例。
  GithubApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'githubApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$githubApiHash();

  @$internal
  @override
  $ProviderElement<GithubApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GithubApi create(Ref ref) {
    return githubApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GithubApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GithubApi>(value),
    );
  }
}

String _$githubApiHash() => r'1a39792d2f8d567b06ff468eeb8ee64b4880a100';
