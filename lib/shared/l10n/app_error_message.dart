import 'package:git_geek/core/error/app_error.dart';

/// AppError → 展示文案：直接透出 Repository 已本地化的 [AppError.message]。
/// 约定 presentation 只调 [toDisplayString]，不手写 `switch (error)` 拼字符串；
/// 如需按类型加前缀/兜底，再在 arb 加 key 后在此扩展。
extension AppErrorDisplayX on AppError {
  String toDisplayString() => message;
}
