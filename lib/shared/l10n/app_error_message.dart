import 'package:git_geek/core/error/app_error.dart';

/// AppError → 展示文案。
///
/// 约定 presentation 只调 [toDisplayString]，不手写 `switch (error)` 拼字符串。
/// 各子类的 `message` 已在 data 边界按调用方语言拼好，默认直接透出；
/// 需要按错误种类加强引导（如提示重试、检查环境）时，在这里集中加。
extension AppErrorDisplayX on AppError {
  /// 面向用户的展示文案。
  String toDisplayString() => message;

  /// 是否值得让用户重试（网络抖动、服务端临时故障）。
  bool get isRetryable => switch (this) {
    NetworkError() || TimeoutError() || ServerError() => true,
    UnauthorizedError() => false,
    GitCommandError() => false,
    PlatformUnsupportedError() => false,
    UnknownError() => false,
  };

  /// 是否属于本机环境问题（git 不可用、平台不支持），
  /// 与网络问题分开引导：这类重试无意义，应提示安装 git 或换平台。
  bool get isEnvironmentIssue => switch (this) {
    GitCommandError() || PlatformUnsupportedError() => true,
    NetworkError() || TimeoutError() || UnauthorizedError() => false,
    ServerError() => false,
    UnknownError() => false,
  };
}
