import 'package:dio/dio.dart';
import 'package:git_geek/core/network/dio_client.dart';
import 'package:git_geek/di/logging.dart';
import 'package:git_geek/di/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network.g.dart';

/// Dio 装配：只负责 GitHub/GitLab 等 HTTP API，不替代本地 git CLI。
/// 本地 git 操作走 `lib/di/git.dart` 的 gitRunnerProvider（Process）。
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/vnd.github+json'},
    ),
  );
  dio.interceptors.add(AuthInterceptor(ref.read(tokenStoreProvider)));
  dio.interceptors.add(DioLogInterceptor(ref.read(loggerProvider)));
  dio.interceptors.add(RetryInterceptor(dio, ref.read(loggerProvider)));
  return dio;
}

/// GitHub API 装配：基于共享 Dio 实例。
@Riverpod(keepAlive: true)
GithubApi githubApi(Ref ref) => GithubApi(ref.watch(dioProvider));
