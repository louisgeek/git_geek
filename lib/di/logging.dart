import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logging.g.dart';

/// 全局日志装配：debug 全量带颜色，release 只留 warning 及以上。
/// 业务统一用 `ref.read(loggerProvider)`，不要再散 `print/debugPrint`。
@Riverpod(keepAlive: true)
Logger logger(Ref ref) {
  return Logger(
    filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
    level: kDebugMode ? Level.trace : Level.warning,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 6,
      lineLength: 120,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
}
