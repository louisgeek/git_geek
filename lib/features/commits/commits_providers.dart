import 'package:git_geek/features/commits/data/sources/git_commit_source.dart';
import 'package:git_geek/core/logging/logger.dart';
import 'package:git_geek/core/git/git_providers.dart';
import 'package:git_geek/features/commits/data/commits_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'commits_providers.g.dart';

/// commits feature 装配（薄封装，autoDispose 即可）。
@riverpod
CommitsRepository commitsRepository(Ref ref) {
  final runner = ref.watch(gitRunnerProvider);
  final resolver = ref.watch(remoteRepoResolverProvider);
  return CommitsRepository(
    GitCommitDataSource(runner, resolver),
    ref.read(loggerProvider),
    resolver,
  );
}
