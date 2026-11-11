import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_geek/app/router/app_router.dart';
import 'package:git_geek/app/theme/app_theme.dart';
import 'package:git_geek/app/theme/theme_mode_notifier.dart';
import 'package:git_geek/core/logging/logger.dart';
import 'package:git_geek/features/workspace/presentation/workspace_notifier.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';
import 'package:git_geek/shared/l10n/strings.dart';

/// 应用根组件 MaterialApp.router：路由、主题、多语言。
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
            systemDefault: appLangFromLocale(
              WidgetsBinding.instance.platformDispatcher.locale,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final ui = ref.watch(workspaceProvider);
    final themeMode = ref.watch(themeModeProvider);
    //把导航控制权交给路由库
    return MaterialApp.router(
      title: 'GitGeek',
      locale: ui.lang.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
