// 领域统一错误：UI 只依赖它，不依赖 Dio 类型。
// DataSource/Repository 把底层异常转成它，Notifier 折叠成 state 的 error 字符串。
sealed class AppError implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  const AppError(this.message, {this.statusCode, this.cause});

  @override
  String toString() => 'AppError($statusCode): $message';
}

/// 网络不可达/连接失败。
final class NetworkError extends AppError {
  const NetworkError(super.message, {super.cause});
}

/// 连接/接收/发送超时。
final class TimeoutError extends AppError {
  const TimeoutError(super.message, {super.cause});
}

/// 401 未授权：token 缺失/过期。当前无登录态，仅透出提示，不做跳转。
final class UnauthorizedError extends AppError {
  const UnauthorizedError(super.message, {super.statusCode, super.cause});
}

/// 5xx/429 等服务端错误。
final class ServerError extends AppError {
  const ServerError(super.message, {super.statusCode, super.cause});
}

///兜底未知错误。
final class UnknownError extends AppError {
  const UnknownError(super.message, {super.statusCode, super.cause});
}
