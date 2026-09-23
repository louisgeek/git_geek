import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:git_geek/core/storage/database.dart';
import 'package:git_geek/core/storage/token_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'storage.g.dart';

/// SharedPreferences 实例：main() 里预加载后 override，业务只读 provider。
/// 普通偏好放这里；token/密码放 [TokenStore]；离线表结构数据放 Sembast。
@Riverpod(keepAlive: true)
SharedPreferences appPrefs(Ref ref) => throw UnimplementedError(
      'appPrefsProvider must be overridden in main() with loaded instance',
    );

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => TokenStore(const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    ));

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
