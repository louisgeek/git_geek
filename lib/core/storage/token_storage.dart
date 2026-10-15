import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 敏感信息：只存 token / 密码类。普通偏好（repoPath/remote/lang）走 SharedPreferences。
/// 装配见 `lib/core/storage/storage_providers.dart`。
class TokenStore {
  static const _kGithubToken = 'gitgeek.github_token';
  static const _kGitlabToken = 'gitgeek.gitlab_token';

  final FlutterSecureStorage _secureStorage;

  TokenStore(this._secureStorage);

  /// 读 GitHub token。
  Future<String?> readGithubToken() => _secureStorage.read(key: _kGithubToken);

  /// 存 GitHub token。
  Future<void> saveGithubToken(String v) =>
      _secureStorage.write(key: _kGithubToken, value: v);

  /// 删 GitHub token。
  Future<void> deleteGithubToken() => _secureStorage.delete(key: _kGithubToken);

  /// 读 GitLab token。
  Future<String?> readGitlabToken() => _secureStorage.read(key: _kGitlabToken);

  /// 存 GitLab token。
  Future<void> saveGitlabToken(String v) =>
      _secureStorage.write(key: _kGitlabToken, value: v);

  /// 删 GitLab token。
  Future<void> deleteGitlabToken() => _secureStorage.delete(key: _kGitlabToken);
}
