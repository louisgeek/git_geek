import 'package:git_geek/core/error/app_error.dart';

/// AppError → 用户可读文案：当前直接透出 message（已在 Repository 层本地化）。
/// 后续如需按类型映射本地化字符串，再在 arb 加 key 后扩展。
extension AppErrorMessageX on AppError {
  String toDisplayString() => message;
}
