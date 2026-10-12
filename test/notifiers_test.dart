import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_geek/core/result.dart';
import 'package:git_geek/core/storage/database.dart';
import 'package:git_geek/data/git_commit_source.dart';
import 'package:git_geek/data/git_runner_stub.dart';
import 'package:git_geek/data/git_tag_source.dart';
import 'package:git_geek/data/remote_repo.dart';
import 'package:git_geek/features/commits/data/commits_repository.dart';
import 'package:git_geek/features/commits/di/providers.dart';
import 'package:git_geek/features/commits/presentation/commits_notifier.dart';
import 'package:git_geek/features/commits/presentation/commits_state.dart';
import 'package:git_geek/features/tags/data/tags_repository.dart';
import 'package:git_geek/features/tags/di/providers.dart';
import 'package:git_geek/features/tags/presentation/tags_notifier.dart';
import 'package:git_geek/l10n/strings.dart';
import 'package:git_geek/models/git_commit.dart';
import 'package:git_geek/models/git_tag.dart';
import 'package:logger/logger.dart';

// 不碰真实 git：fake 仓储直接返回固定数据。
final _fakeRunner = NoopGitRunner();

class FakeTagsRepository extends TagsRepository {
  FakeTagsRepository()
      : super(AppDatabase.memory(), Logger(),
            GitTagDataSource(_fakeRunner, RemoteRepoResolver(_fakeRunner)),
            RemoteRepoResolver(_fakeRunner));

  @override
  Future<Result<String>> resolveDir(
          String repoPath, String scope, AppLang lang) async =>
      const Result.ok('.');

  @override
  Future<Result<List<GitTag>>> fetchLocalTags(
          String dir, AppLang lang) async =>
      const Result.ok([
        GitTag(name: 'v1.0.0', commitSha: 'aaa'),
        GitTag(name: 'v2.0.0'),
      ]);

  @override
  Future<Result<List<GitTag>>> fetchRemoteTags(
          String dir, String remote, AppLang lang) async =>
      const Result.ok([
        GitTag(name: 'v1.0.0', commitSha: 'aaa', source: TagSource.remote),
      ]);
}

/// 远程读取失败、缓存有数据：应走兜底并置 remoteFromCache。
class FailingRemoteTagsRepository extends FakeTagsRepository {
  @override
  Future<Result<List<GitTag>>> fetchRemoteTags(
          String dir, String remote, AppLang lang) async =>
      const Result.err('network down');

  @override
  Future<List<GitTag>> cachedRemoteTags(
    String dir,
    String remote, {
    Duration maxAge = const Duration(days: 7),
  }) async =>
      const [
        GitTag(name: 'v9.9.9', commitSha: 'zzz', source: TagSource.remote),
      ];
}

class FakeCommitsRepository extends CommitsRepository {
  FakeCommitsRepository()
      : super(
            GitCommitDataSource(_fakeRunner, RemoteRepoResolver(_fakeRunner)),
            Logger(),
            RemoteRepoResolver(_fakeRunner));

  @override
  Future<Result<String>> resolveEffectiveDir(
          String repoPath, String scope, AppLang lang) async =>
      const Result.ok('.');

  @override
  Future<bool> isRemoteAndNotCached(String repoPath) async => false;

  @override
  Future<Result<List<GitCommit>>> fetchCommits(
          String dir, String branch, int limit, AppLang lang) async =>
      const Result.ok([
        GitCommit(
          sha: 'newsha',
          parents: ['basesha'],
          author: 'louis',
          subject: 'feat: dark mode',
          submoduleChanges: [
            SubmoduleChange(path: 'pkg', oldSha: 's1', newSha: 's2'),
          ],
        ),
        GitCommit(
          sha: 'basesha',
          author: 'louis',
          subject: 'fix: crash on start',
        ),
      ]);

  @override
  Future<Result<List<GitBranch>>> fetchBranches(
          String dir, AppLang lang) async =>
      const Result.ok([GitBranch(name: 'main', isCurrent: true)]);

  @override
  Future<Result<List<GitSubmodule>>> fetchSubmodules(
          String dir, AppLang lang) async =>
      const Result.ok([GitSubmodule(path: 'pkg', sha: 's1')]);

  @override
  Future<Result<String>> fetchRemoteUrl(
          String dir, String remote, AppLang lang) async =>
      const Result.ok('https://example.com/r.git');

  @override
  Future<Result<String>> fetchSubmoduleBranch(
          String dir, String subPath, AppLang lang) async =>
      const Result.ok('main');
}

void main() {
  group('TagsNotifier', () {
    test('load fetches local and remote into state', () async {
      final container = ProviderContainer(
        overrides: [
          tagsRepositoryProvider.overrideWithValue(FakeTagsRepository()),
        ],
      );
      addTearDown(container.dispose);
      container.listen(tagsProvider, (_, _) {});

      await container
          .read(tagsProvider.notifier)
          .load(repoPath: 'r', remote: 'origin', lang: AppLang.zh);
      final state = container.read(tagsProvider);
      expect(state.localTags.map((e) => e.name), ['v1.0.0', 'v2.0.0']);
      expect(state.remoteTags.map((e) => e.name), ['v1.0.0']);
      final items = buildCompareItems(state.localTags, state.remoteTags);
      expect(
        items.firstWhere((e) => e.name == 'v1.0.0').status,
        TagSyncStatus.synced,
      );
    });

    test('remote failure falls back to cache', () async {
      final container = ProviderContainer(
        overrides: [
          tagsRepositoryProvider
              .overrideWithValue(FailingRemoteTagsRepository()),
        ],
      );
      addTearDown(container.dispose);
      container.listen(tagsProvider, (_, _) {});

      await container
          .read(tagsProvider.notifier)
          .load(repoPath: 'r', remote: 'origin', lang: AppLang.zh);
      final state = container.read(tagsProvider);
      expect(state.remoteFromCache, isTrue);
      expect(state.remoteTags.single.name, 'v9.9.9');
    });

    test('setters only touch their own field', () async {
      final container = ProviderContainer(
        overrides: [
          tagsRepositoryProvider.overrideWithValue(FakeTagsRepository()),
        ],
      );
      addTearDown(container.dispose);
      container.listen(tagsProvider, (_, _) {});

      final notifier = container.read(tagsProvider.notifier);
      notifier.setQuery('v1');
      notifier.setSort(TagSortMode.nameAsc);
      notifier.setFilter(TagFilter.onlyLocal);
      final state = container.read(tagsProvider);
      expect(state.query, 'v1');
      expect(state.sortMode, TagSortMode.nameAsc);
      expect(state.filter, TagFilter.onlyLocal);
    });
  });

  group('CommitsNotifier', () {
    test('load resolves once then fills branches and submodules', () async {
      final container = ProviderContainer(
        overrides: [
          commitsRepositoryProvider
              .overrideWithValue(FakeCommitsRepository()),
        ],
      );
      addTearDown(container.dispose);
      container.listen(commitsProvider, (_, _) {});

      await container.read(commitsProvider.notifier).load(
            repoPath: 'r',
            scope: '',
            branch: 'main',
            limit: 100,
            remote: 'origin',
            lang: AppLang.zh,
          );
      final state = container.read(commitsProvider);
      expect(state.commits.length, 2);
      expect(state.branches.single.name, 'main');
      expect(state.submodules.single.path, 'pkg');
      expect(state.remoteUrl, 'https://example.com/r.git');
      expect(state.submoduleBranches['pkg'], 'main');
      expect(state.branch, 'main');
    });

    test('query filters visibleCommits and toggle reverses order', () async {
      final container = ProviderContainer(
        overrides: [
          commitsRepositoryProvider
              .overrideWithValue(FakeCommitsRepository()),
        ],
      );
      addTearDown(container.dispose);
      container.listen(commitsProvider, (_, _) {});

      final notifier = container.read(commitsProvider.notifier);
      await notifier.load(
        repoPath: 'r',
        scope: '',
        branch: '',
        limit: 100,
        remote: 'origin',
        lang: AppLang.zh,
      );
      notifier.setCommitQuery('dark mode');
      var state = container.read(commitsProvider);
      expect(state.visibleCommits.length, 1);
      expect(state.visibleCommits.single.sha, 'newsha');

      notifier.setCommitQuery('');
      notifier.toggleOrder();
      state = container.read(commitsProvider);
      expect(state.newestFirst, isFalse);
      expect(state.visibleCommits.first.sha, 'basesha');
    });
  });
}
