import 'package:git_geek/features/tags/data/sources/git_tag_source.dart';
import 'package:git_geek/core/logging/logger.dart';
import 'package:git_geek/core/storage/storage_providers.dart';
import 'package:git_geek/core/git/git_providers.dart';
import 'package:git_geek/features/tags/data/tags_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tags_providers.g.dart';

/// tags feature 装配（薄封装，autoDispose 即可）。
@riverpod
TagsRepository tagsRepository(Ref ref) {
  final runner = ref.watch(gitRunnerProvider);
  final resolver = ref.watch(remoteRepoResolverProvider);
  return TagsRepository(
    ref.watch(appDatabaseProvider),
    ref.read(loggerProvider),
    GitTagDataSource(runner, resolver),
    resolver,
  );
}
