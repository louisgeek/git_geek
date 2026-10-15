import 'package:git_geek/core/error/result.dart';

/// Result 的常用扩展：when 穷举、valueOrNull 快捷取值。
extension ResultX<T> on Result<T> {
  /// 穷举成功/失败，UI 层折叠 state 时用。
  R when<R>({
    required R Function(T value) success,
    required R Function(String message, Object? cause) failure,
  }) => switch (this) {
    Success(:final value) => success(value),
    Failure(:final message, :final cause) => failure(message, cause),
  };
}
