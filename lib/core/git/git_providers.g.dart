// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'git_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 本地 git 执行器装配：桌面/移动走 IoGitRunner，Web 走 NoopGitRunner。
/// 无状态应用单例，keepAlive 常驻；测试用 overrideWithValue(fake) 替换。

@ProviderFor(gitRunner)
final gitRunnerProvider = GitRunnerProvider._();

/// 本地 git 执行器装配：桌面/移动走 IoGitRunner，Web 走 NoopGitRunner。
/// 无状态应用单例，keepAlive 常驻；测试用 overrideWithValue(fake) 替换。

final class GitRunnerProvider
    extends $FunctionalProvider<GitRunner, GitRunner, GitRunner>
    with $Provider<GitRunner> {
  /// 本地 git 执行器装配：桌面/移动走 IoGitRunner，Web 走 NoopGitRunner。
  /// 无状态应用单例，keepAlive 常驻；测试用 overrideWithValue(fake) 替换。
  GitRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gitRunnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gitRunnerHash();

  @$internal
  @override
  $ProviderElement<GitRunner> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GitRunner create(Ref ref) {
    return gitRunner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GitRunner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GitRunner>(value),
    );
  }
}

String _$gitRunnerHash() => r'a5e199481c2628f0449978c7b921ac118dc9d441';

/// 远程仓库解析器装配：实例类，构造注入 GitRunner，进程级串行锁在实例内。

@ProviderFor(remoteRepoResolver)
final remoteRepoResolverProvider = RemoteRepoResolverProvider._();

/// 远程仓库解析器装配：实例类，构造注入 GitRunner，进程级串行锁在实例内。

final class RemoteRepoResolverProvider
    extends
        $FunctionalProvider<
          RemoteRepoResolver,
          RemoteRepoResolver,
          RemoteRepoResolver
        >
    with $Provider<RemoteRepoResolver> {
  /// 远程仓库解析器装配：实例类，构造注入 GitRunner，进程级串行锁在实例内。
  RemoteRepoResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteRepoResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteRepoResolverHash();

  @$internal
  @override
  $ProviderElement<RemoteRepoResolver> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteRepoResolver create(Ref ref) {
    return remoteRepoResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteRepoResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteRepoResolver>(value),
    );
  }
}

String _$remoteRepoResolverHash() =>
    r'b37e0563ae632bbefdba3412dde32d4cd941c45e';

/// 是否支持本地 git：桌面/移动为 true，Web 等无 git 平台为 false。
/// UI/Notifier 统一经此 provider 读取，禁止再直引全局单例。

@ProviderFor(supportsNativeGit)
final supportsNativeGitProvider = SupportsNativeGitProvider._();

/// 是否支持本地 git：桌面/移动为 true，Web 等无 git 平台为 false。
/// UI/Notifier 统一经此 provider 读取，禁止再直引全局单例。

final class SupportsNativeGitProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 是否支持本地 git：桌面/移动为 true，Web 等无 git 平台为 false。
  /// UI/Notifier 统一经此 provider 读取，禁止再直引全局单例。
  SupportsNativeGitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportsNativeGitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportsNativeGitHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return supportsNativeGit(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$supportsNativeGitHash() => r'a2fda9a1decdf5db3267fe720db6b9a8ab7417a3';
