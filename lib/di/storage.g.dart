// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SharedPreferences 实例：main() 里预加载后 override，业务只读 provider。
/// 普通偏好放这里；token/密码放 [TokenStore]；离线表结构数据放 Sembast。

@ProviderFor(appPrefs)
final appPrefsProvider = AppPrefsProvider._();

/// SharedPreferences 实例：main() 里预加载后 override，业务只读 provider。
/// 普通偏好放这里；token/密码放 [TokenStore]；离线表结构数据放 Sembast。

final class AppPrefsProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// SharedPreferences 实例：main() 里预加载后 override，业务只读 provider。
  /// 普通偏好放这里；token/密码放 [TokenStore]；离线表结构数据放 Sembast。
  AppPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appPrefsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appPrefsHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return appPrefs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$appPrefsHash() => r'a59700ea41e8ee64793129da9b497246e8966a1c';

/// Token 存储装配：基于安全存储，用于 GitHub/GitLab token。

@ProviderFor(tokenStore)
final tokenStoreProvider = TokenStoreProvider._();

/// Token 存储装配：基于安全存储，用于 GitHub/GitLab token。

final class TokenStoreProvider
    extends $FunctionalProvider<TokenStore, TokenStore, TokenStore>
    with $Provider<TokenStore> {
  /// Token 存储装配：基于安全存储，用于 GitHub/GitLab token。
  TokenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStoreHash();

  @$internal
  @override
  $ProviderElement<TokenStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenStore create(Ref ref) {
    return tokenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenStore>(value),
    );
  }
}

String _$tokenStoreHash() => r'53547a9e1a333765e9f3c2c07caa06e2f047368c';

/// 离线数据库装配：remote tags 兜底缓存，退出时自动关闭。

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// 离线数据库装配：remote tags 兜底缓存，退出时自动关闭。

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// 离线数据库装配：remote tags 兜底缓存，退出时自动关闭。
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';
