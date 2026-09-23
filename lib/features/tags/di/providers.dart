import 'package:git_geek/data/git_runner.dart';
import 'package:git_geek/data/git_tag_source.dart';
import 'package:git_geek/di/logging.dart';
import 'package:git_geek/di/storage.dart';
import 'package:git_geek/features/tags/data/tags_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// tags feature 装配（薄封装，autoDispose 即可）。
@riverpod
TagsRepository tagsRepository(Ref ref) {
  return TagsRepository(
    ref.watch(appDatabaseProvider),
    ref.read(loggerProvider),
    GitTagDataSource(gitRunner),
  );
}
