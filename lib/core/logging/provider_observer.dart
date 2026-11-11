import 'package:logger/logger.dart';
import 'package:riverpod/misc.dart' show ProviderException;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod 容器观察者：provider 失败的统一转发入口（挂 `ProviderScope.observers`）。
///
/// `providerDidFail` 按 Riverpod 3.0 新签名（单个 [ProviderObserverContext] 参数）
/// 转发 error 级；转发前先跳过 `ProviderException`——依赖链上游失败会把下游
/// provider 也标记为失败，跳过才能让同一根因只经真正抛错的源头上报一次。
final class RiverpodObserver extends ProviderObserver {
  final Logger _log;

  RiverpodObserver(this._log);

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (error is ProviderException) return;
    _log.e(
      '[riverpod] provider 失败: ${context.provider}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
