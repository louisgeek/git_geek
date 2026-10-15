import 'package:dio/dio.dart';
import 'package:git_geek/core/logging/logger.dart';
import 'package:git_geek/core/network/dio_factory.dart';
import 'package:git_geek/core/network/github_api.dart';
import 'package:git_geek/core/network/interceptors/auth_interceptor.dart';
import 'package:git_geek/core/network/interceptors/error_interceptor.dart';
import 'package:git_geek/core/network/interceptors/logging_interceptor.dart';
import 'package:git_geek/core/storage/storage_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_providers.g.dart';

/// Dio 装配：只负责 GitHub/GitLab 等 HTTP API，不替代本地 git CLI。
/// 本地 git 操作走 `lib/core/git/git_providers.dart` 的 gitRunnerProvider（Process）。
/// 挂载顺序：logging → auth → error。
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = buildDio();
  dio.interceptors.add(DioLogInterceptor(ref.read(loggerProvider)));
  dio.interceptors.add(AuthInterceptor(ref.read(tokenStoreProvider)));
  dio.interceptors.add(ErrorInterceptor(dio, ref.read(loggerProvider)));
  return dio;
}

/// GitHub API 装配：基于共享 Dio 实例。
@Riverpod(keepAlive: true)
GithubApi githubApi(Ref ref) => GithubApi(ref.watch(dioProvider));
