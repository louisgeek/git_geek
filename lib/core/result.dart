/// 跨 feature 共用的 Result 类型：替代抛异常/接异常的错误传递。
/// 约定：DataSource/Repository 返回 `Result`（失败带本地化 `message`），
/// Notifier 用 `switch` 折叠进 state 的 error 字符串；UI 层只读字符串。
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;

  const factory Result.err(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) = Err<T>;

  bool get isOk => this is Ok<T>;

  bool get isErr => this is Err<T>;

  /// 成功取值，失败返回 `null`（需要区分时用 `switch` 穷举）。
  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };

  /// 失败信息，成功返回 `null`。
  String? get errorOrNull => switch (this) {
    Ok() => null,
    Err(:final message) => message,
  };

  R fold<R>(R Function(T value) onOk, R Function(Err<T> err) onErr) =>
      switch (this) {
        Ok(:final value) => onOk(value),
        Err() => onErr(this as Err<T>),
      };

  Result<U> map<U>(U Function(T value) f) => switch (this) {
    Ok(:final value) => Result.ok(f(value)),
    Err(:final message, :final cause, :final stackTrace) => Result.err(
      message,
      cause: cause,
      stackTrace: stackTrace,
    ),
  };
}

/// 成功：包一层值。
final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

/// 失败：`message` 给 UI 直接显示，`cause`/`stackTrace` 给日志。
final class Err<T> extends Result<T> {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  const Err(this.message, {this.cause, this.stackTrace});
}

/// 把捕获的异常转成干净的展示信息（反复脱 `Exception: ` 前缀）。
String cleanError(Object e) {
  var s = e.toString();
  const prefix = 'Exception: ';
  while (s.startsWith(prefix)) {
    s = s.substring(prefix.length);
  }
  return s;
}
