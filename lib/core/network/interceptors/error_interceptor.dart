import 'package:dio/dio.dart';
import 'package:git_geek/core/error/app_error.dart';
import 'package:logger/logger.dart';

/// 最后一环：幂等 GET 重试 + DioException → AppError 映射。
/// 拦截器只打 method/url/status，不打 body（防 token 泄漏）。
class ErrorInterceptor extends Interceptor {
  final Dio _dio;
  final Logger _log;

  /// 最大重试次数。
  final int maxRetries;

  ErrorInterceptor(this._dio, this._log, {this.maxRetries = 2});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    // 取消不重试，直接映射后透出。
    if (err.type == DioExceptionType.cancel ||
        req.cancelToken?.isCancelled == true) {
      return handler.reject(
        DioException(
          requestOptions: req,
          error: const UnknownError('请求已取消'),
          type: DioExceptionType.cancel,
        ),
      );
    }
    // 幂等 GET 重试：429/5xx 与连接超时最多重试 2 次。
    if (req.method.toUpperCase() == 'GET') {
      final status = err.response?.statusCode;
      final retryableStatus =
          status == 429 || (status != null && status >= 500 && status < 600);
      final retryableNet =
          status == null &&
          (err.type == DioExceptionType.connectionTimeout ||
              err.type == DioExceptionType.receiveTimeout ||
              err.type == DioExceptionType.connectionError);
      final attempt = (req.extra['retry_attempt'] as int?) ?? 0;
      if ((retryableStatus || retryableNet) && attempt < maxRetries) {
        final next = attempt + 1;
        req.extra['retry_attempt'] = next;
        _log.d('[network] retry $next/$maxRetries ${req.method} ${req.uri}');
        await Future.delayed(Duration(milliseconds: 500 * next));
        try {
          final res = await _dio.fetch<List<dynamic>>(req);
          return handler.resolve(res);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
    }
    handler.next(_mapToAppError(err));
  }

  /// DioException → AppError：调用方只依赖 AppError，不依赖 Dio 类型。
  static DioException _mapToAppError(DioException e) {
    final status = e.response?.statusCode;
    final AppError appError;
    if (status == 401) {
      appError = UnauthorizedError(
        e.message ?? '未授权',
        statusCode: status,
        cause: e,
      );
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      appError = TimeoutError(e.message ?? '请求超时', cause: e);
    } else if (e.type == DioExceptionType.connectionError) {
      appError = NetworkError(e.message ?? '网络不可达', cause: e);
    } else if (status != null && status >= 500 && status < 600 ||
        status == 429) {
      appError = ServerError(
        e.message ?? '服务端错误',
        statusCode: status,
        cause: e,
      );
    } else {
      appError = UnknownError(
        e.message ?? e.toString(),
        statusCode: status,
        cause: e,
      );
    }
    return DioException(
      requestOptions: e.requestOptions,
      response: e.response,
      type: e.type,
      error: appError,
    );
  }
}
