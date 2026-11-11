import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_geek/app/app.dart';
import 'package:git_geek/core/git/git_providers.dart';
import 'package:git_geek/core/logging/logger.dart';
import 'package:git_geek/core/logging/provider_observer.dart';
import 'package:git_geek/core/storage/app_prefs.dart';
import 'package:git_geek/core/storage/storage_providers.dart';
import 'package:git_geek/features/commits/commits_providers.dart';
import 'package:git_geek/features/commits/data/commits_repository.dart';
import 'package:git_geek/features/commits/data/sources/git_commit_source.dart';
import 'package:git_geek/features/tags/data/sources/git_tag_source.dart';
import 'package:git_geek/features/tags/data/tags_repository.dart';
import 'package:git_geek/features/tags/tags_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 组合根（Composition Root）。
///
/// 全应用只在这里决定「哪个接口配哪个实现」：用 `ProviderScope.overrides`
/// 把 data 层实现绑到 feature 声明的 domain 契约上。各 feature 只声明自己
/// 需要的契约，不自己 `new` 实现，也不 import 对方或自己的 data 层。
///
/// 用 `overrideWith` 工厂而非 `overrideWithValue`：实现延迟到首次读取时构造，
/// 既能 `ref.watch` 复用容器内单例（GitRunner / Logger / AppDatabase），
/// 又不必在 bootstrap 里预先求值，避免启动期就触发 git 环境探测。
Future<void> bootstrapAndRun() async {
  // 确保 Flutter 的核心绑定已经初始化完成。
  WidgetsFlutterBinding.ensureInitialized();

  // 错误兜底的 Logger 在容器创建之前注册，取不到 provider 实例，
  // 用同一份工厂配置（buildDefaultLogger）保持行为一致。
  final log = buildDefaultLogger();

  // 全局错误兜底：先挂上，避免 prefs 加载期异常裸奔。
  // 两入口互补、不保证全覆盖（isolate/原生侧按各自机制处理）。
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log.e('FlutterError: ${details.exception}',
        error: details.exception, stackTrace: details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log.e('PlatformError: $error', error: error, stackTrace: stack);
    return true;
  };

  // 只有异步实例才在启动期预加载；同步 const 构造留在各自 provider 里懒创建。
  // key 与老 GitTagSettings 一致（gitgeek.*），老数据直接复用。
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // Riverpod 侧错误上报：provider 失败经 observer 转发 error 级。
      observers: [RiverpodObserver(log)],
      overrides: [
        appPrefsProvider.overrideWithValue(prefs),

        // ---- Repository 装配：唯一一处把 data 实现绑到 domain 契约 ----
        tagsRepositoryProvider.overrideWith(
          (ref) => TagsRepository(
            ref.watch(appDatabaseProvider),
            ref.watch(loggerProvider),
            GitTagDataSource(
              ref.watch(gitRunnerProvider),
              ref.watch(remoteRepoResolverProvider),
            ),
            ref.watch(remoteRepoResolverProvider),
          ),
        ),
        commitsRepositoryProvider.overrideWith(
          (ref) => CommitsRepository(
            GitCommitDataSource(
              ref.watch(gitRunnerProvider),
              ref.watch(remoteRepoResolverProvider),
            ),
            ref.watch(loggerProvider),
            ref.watch(remoteRepoResolverProvider),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
