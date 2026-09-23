import 'package:git_geek/data/git_commit_source.dart';
import 'package:git_geek/data/git_runner.dart';
import 'package:git_geek/di/logging.dart';
import 'package:git_geek/features/commits/data/commits_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// commits feature 装配（薄封装，autoDispose 即可）。
@riverpod
CommitsRepository commitsRepository(Ref ref) {
  return CommitsRepository(
    ref.read(loggerProvider),
    GitCommitDataSource(gitRunner),
  );
}
