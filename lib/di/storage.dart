import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:git_geek/core/storage/database.dart';
import 'package:git_geek/core/storage/token_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage.g.dart';

/// Token 存储装配：基于安全存储，用于 GitHub/GitLab token。
@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => TokenStore(const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    ));

/// 离线数据库装配：remote tags 兜底缓存，退出时自动关闭。
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
