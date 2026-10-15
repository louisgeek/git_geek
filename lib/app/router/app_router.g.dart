// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 路由装配：StatefulShellRoute 双分支（/tags 对比页与 /commits 日志页互保活），
/// `/` 重定向到 `/tags`。未涉及登录态 redirect、deeplink，先不建。

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// 路由装配：StatefulShellRoute 双分支（/tags 对比页与 /commits 日志页互保活），
/// `/` 重定向到 `/tags`。未涉及登录态 redirect、deeplink，先不建。

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// 路由装配：StatefulShellRoute 双分支（/tags 对比页与 /commits 日志页互保活），
  /// `/` 重定向到 `/tags`。未涉及登录态 redirect、deeplink，先不建。
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'624e2ea70bded1382563ac89413ba2bfb9524911';
