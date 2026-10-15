import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

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
