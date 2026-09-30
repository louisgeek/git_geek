import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';
import 'package:git_geek/l10n/strings.dart';
import 'package:git_geek/di/logging.dart';
import 'package:git_geek/di/router.dart';
import 'package:git_geek/di/storage.dart';
import 'package:git_geek/features/workspace/presentation/workspace_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用入口：预加载偏好后启动，偏好经 ProviderScope 注入。
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 预加载 prefs：SettingsRepository 唯一偏好源（override）。
  // key 与老 GitTagSettings 一致（gitgeek.*），老数据直接复用。
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [appPrefsProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

/// 应用根组件：装配路由、语言、明暗主题。
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    ref.read(loggerProvider).i('GitGeek starting');
    // 首帧后异步初始化 workspace，避免在 initState 同步读写 provider。
    Future.microtask(
      () => ref.read(workspaceProvider.notifier).init(
            systemDefault: AppLang.fromLocale(
              WidgetsBinding.instance.platformDispatcher.locale,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final ui = ref.watch(workspaceProvider);
    return MaterialApp.router(
      title: 'GitGeek',
      locale: ui.lang.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
