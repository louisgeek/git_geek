import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger.g.dart';

/// 全局日志装配：debug 全量带颜色，release 只留 warning 及以上。
/// 业务统一用 `ref.read(loggerProvider)`，不要再散 `print/debugPrint`。
@Riverpod(keepAlive: true)
Logger logger(Ref ref) => buildDefaultLogger();

/// 默认 Logger 工厂：provider 装配与组合根错误兜底（bootstrap 注册发生在
/// 容器创建之前，取不到 provider 实例）共用同一份配置。
Logger buildDefaultLogger() => Logger(
      filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
      level: kDebugMode ? Level.trace : Level.warning,
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 6,
        lineLength: 120,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
