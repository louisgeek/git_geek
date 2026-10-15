import 'package:dio/dio.dart';
import 'package:git_geek/core/storage/token_storage.dart';

/// 只对 github api 自动带 token，避免污染其他 host。
class AuthInterceptor extends Interceptor {
  final TokenStore _tokenStore;

  AuthInterceptor(this._tokenStore);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.uri.host == 'api.github.com') {
      final token = await _tokenStore.readGithubToken();
      if (token != null && token.trim().isNotEmpty) {
        options.headers['Authorization'] = 'Bearer ${token.trim()}';
      }
    }
    handler.next(options);
  }
}
