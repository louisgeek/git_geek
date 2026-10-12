import 'package:dio/dio.dart';
import 'package:git_geek/core/storage/token_store.dart';
import 'package:logger/logger.dart';

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

/// 轻量请求日志：只打 method/url/status，不打 body（避免泄漏 token 与刷屏）。
class DioLogInterceptor extends Interceptor {
  final Logger _log;

  DioLogInterceptor(this._log);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.d('--> ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log.d('<-- ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.w(
      '<-- ${err.response?.statusCode ?? '-'} ${err.requestOptions.uri}',
      error: err.message,
    );
    handler.next(err);
  }
}

/// 幂等 GET 重试：429/5xx 与连接超时最多重试 2 次，取消不重试。
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final Logger _log;

  /// 最大重试次数。
  final int maxRetries;

  RetryInterceptor(this._dio, this._log, {this.maxRetries = 2});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    if (err.type == DioExceptionType.cancel ||
        req.cancelToken?.isCancelled == true) {
      return handler.next(err);
    }
    if (req.method.toUpperCase() != 'GET') return handler.next(err);
    final status = err.response?.statusCode;
    final retryableStatus =
        status == 429 || (status != null && status >= 500 && status < 600);
    final retryableNet =
        status == null &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError);
    final attempt = (req.extra['retry_attempt'] as int?) ?? 0;
    if ((!retryableStatus && !retryableNet) || attempt >= maxRetries) {
      return handler.next(err);
    }
    final next = attempt + 1;
    // 重试计数存 extra，防无限重试。
    req.extra['retry_attempt'] = next;
    _log.d('[network] retry $next/$maxRetries ${req.method} ${req.uri}');
    // 递增退避，避免打爆服务端。
    await Future.delayed(Duration(milliseconds: 500 * next));
    try {
      final res = await _dio.fetch<List<dynamic>>(req);
      return handler.resolve(res);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}

/// 领域异常：调用方只依赖它，不依赖 Dio 类型。
class GithubApiException implements Exception {
  final int? statusCode;
  final String message;

  const GithubApiException(this.message, {this.statusCode});

  @override
  String toString() => 'GithubApiException($statusCode): $message';
}

/// GitHub REST 最小封装：按需取 remote tags，避免每次都 `git ls-remote`。
class GithubApi {
  final Dio _dio;

  GithubApi(this._dio);

  /// `GET /repos/{owner}/{repo}/tags`，调用方自己解析 owner/repo。
  /// 支持外部传入 [cancelToken] 做取消；失败抛 [GithubApiException]。
  Future<List<Map<String, dynamic>>> listTags({
    required String owner,
    required String repo,
    int perPage = 100,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        'https://api.github.com/repos/$owner/$repo/tags',
        queryParameters: {'per_page': perPage},
        cancelToken: cancelToken,
      );
      final data = res.data ?? const [];
      return data.whereType<Map<String, dynamic>>().toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      throw GithubApiException(
        e.message ?? e.toString(),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
