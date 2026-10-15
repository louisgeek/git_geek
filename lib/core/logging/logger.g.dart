// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 全局日志装配：debug 全量带颜色，release 只留 warning 及以上。
/// 业务统一用 `ref.read(loggerProvider)`，不要再散 `print/debugPrint`。

@ProviderFor(logger)
final loggerProvider = LoggerProvider._();

/// 全局日志装配：debug 全量带颜色，release 只留 warning 及以上。
/// 业务统一用 `ref.read(loggerProvider)`，不要再散 `print/debugPrint`。

final class LoggerProvider extends $FunctionalProvider<Logger, Logger, Logger>
    with $Provider<Logger> {
  /// 全局日志装配：debug 全量带颜色，release 只留 warning 及以上。
  /// 业务统一用 `ref.read(loggerProvider)`，不要再散 `print/debugPrint`。
  LoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerHash();

  @$internal
  @override
  $ProviderElement<Logger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Logger create(Ref ref) {
    return logger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Logger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Logger>(value),
    );
  }
}

String _$loggerHash() => r'349a50ed1aba0cd679f18bc58732925e8d2b7e1b';
