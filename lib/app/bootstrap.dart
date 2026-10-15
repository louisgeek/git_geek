import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_geek/app/app.dart';
import 'package:git_geek/core/storage/app_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 启动流程：初始化 Flutter 环境、预加载存储实例、全局错误捕获。
/// 实例通过 ProviderScope.overrides 注入，不读取令牌（无登录态，先不涉及 session）。
Future<void> bootstrapAndRun() async {
  //确保 Flutter 的核心绑定已经初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  // 全局错误兜底：先挂上，避免 prefs 加载期异常裸奔。
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformError: $error');
    return true;
  };

  // 预加载 prefs：SettingsRepository 唯一偏好源（override）。
  // key 与老 GitTagSettings 一致（gitgeek.*），老数据直接复用。
  final prefs = await SharedPreferences.getInstance();
  runApp(
    //设置 ProviderScope 为根 Widget，所有 Provider 状态都存储在这里（用 ProviderScope 包裹整个应用，作为状态容器）
    ProviderScope(  //ProviderScope 继承自 StatefulWidget
      overrides: [appPrefsProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}
