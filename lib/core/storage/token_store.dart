import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 敏感信息：只存 token / 密码类。普通偏好（repoPath/remote/lang）走 SharedPreferences。
/// 装配见 `lib/di/storage.dart`。
class TokenStore {
  static const _kGithubToken = 'gitgeek.github_token';
  static const _kGitlabToken = 'gitgeek.gitlab_token';

  final FlutterSecureStorage _storage;
  TokenStore(this._storage);

  Future<String?> readGithubToken() => _storage.read(key: _kGithubToken);
  Future<void> saveGithubToken(String v) =>
      _storage.write(key: _kGithubToken, value: v);
  Future<void> deleteGithubToken() => _storage.delete(key: _kGithubToken);

  Future<String?> readGitlabToken() => _storage.read(key: _kGitlabToken);
  Future<void> saveGitlabToken(String v) =>
      _storage.write(key: _kGitlabToken, value: v);
  Future<void> deleteGitlabToken() => _storage.delete(key: _kGitlabToken);
}
