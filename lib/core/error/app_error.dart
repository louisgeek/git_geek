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

/// 本地 git CLI 执行失败（非零退出、命令缺失、仓库不可用等）。
/// git 是本地进程而非网络调用，单列一类才能让调用方区分
/// 「环境问题」与「网络问题」，分别给不同引导文案。
final class GitCommandError extends AppError {
  /// git 进程退出码；命令未启动时为 `null`。
  final int? exitCode;

  /// 触发失败的子命令（如 `log`、`ls-remote`），便于日志定位。
  final String? command;

  const GitCommandError(
    super.message, {
    this.exitCode,
    this.command,
    super.cause,
  });
}

/// 当前平台不支持本地 git（如 Web）。
final class PlatformUnsupportedError extends AppError {
  const PlatformUnsupportedError(super.message, {super.cause});
}
