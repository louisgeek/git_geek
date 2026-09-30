import 'package:git_geek/core/result.dart';
import 'package:git_geek/features/tags/di/providers.dart';
import 'package:git_geek/features/tags/presentation/tags_state.dart';
import 'package:git_geek/l10n/strings.dart';
import 'package:git_geek/models/git_tag.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tags_notifier.g.dart';

/// Tags 子 Notifier（新架构）：唯一持有 local/remote tags + 查询/排序/过滤。
/// 远程读取失败时读本地缓存兜底（[TagsState.remoteFromCache]）。
/// 装配 `TagsRepository` 见 `features/tags/di/providers.dart`。
@riverpod
class TagsNotifier extends _$TagsNotifier {
  @override
  TagsState build() => const TagsState();

  /// 本地 + 远程（含缓存兜底），scope 用于子模块（'' = 主仓库）。
  Future<void> load({
    required String repoPath,
    required String remote,
    String scope = '',
    required AppLang lang,
  }) async {
    await Future.wait([
      loadLocal(repoPath: repoPath, scope: scope, lang: lang),
      loadRemote(repoPath: repoPath, remote: remote, scope: scope, lang: lang),
    ]);
  }

  Future<void> loadLocal({
    required String repoPath,
    String scope = '',
    required AppLang lang,
  }) async {
    final tr = t(lang);
    state = state.copyWith(isLoadingLocal: true, localError: null);
    final repo = ref.read(tagsRepositoryProvider);
    switch (await repo.resolveDir(repoPath, scope, lang)) {
      case Err(:final message):
        state = state.copyWith(
          isLoadingLocal: false,
          localError: message,
        );
        return;
      case Ok(value: final dir):
        switch (await repo.fetchLocalTags(dir, lang)) {
          case Ok(value: final tags):
            state = state.copyWith(
              isLoadingLocal: false,
              localTags: tags,
              lastRefreshInfo: tr.localTagsOk(tags.length),
            );
          case Err(:final message):
            state = state.copyWith(
              isLoadingLocal: false,
              localError: message,
            );
        }
    }
  }

  Future<void> loadRemote({
    required String repoPath,
    required String remote,
    String scope = '',
    required AppLang lang,
  }) async {
    final tr = t(lang);
    state = state.copyWith(isLoadingRemote: true, remoteError: null);
    final repo = ref.read(tagsRepositoryProvider);
    switch (await repo.resolveDir(repoPath, scope, lang)) {
      case Err(:final message):
        state = state.copyWith(
          isLoadingRemote: false,
          remoteError: message,
        );
        return;
      case Ok(value: final dir):
        final trimmedRemote =
            remote.trim().isEmpty ? 'origin' : remote.trim();
        switch (await repo.fetchRemoteTags(dir, trimmedRemote, lang)) {
          case Ok(value: final tags):
            state = state.copyWith(
              isLoadingRemote: false,
              remoteTags: tags,
              remoteFromCache: false,
              lastRefreshInfo: tr.remoteTagsOk(tags.length),
            );
          case Err(:final message):
            final cached = await repo.cachedRemoteTags(dir, trimmedRemote);
            if (cached.isEmpty) {
              state = state.copyWith(
                isLoadingRemote: false,
                remoteError: message,
              );
            } else {
              state = state.copyWith(
                isLoadingRemote: false,
                remoteTags: cached,
                remoteFromCache: true,
                lastRefreshInfo: tr.remoteTagsFromCache(cached.length),
              );
            }
        }
    }
  }

  void setSample(List<GitTag> local, List<GitTag> remote, AppLang lang) {
    state = state.copyWith(
      localTags: local,
      remoteTags: remote,
      localError: null,
      remoteError: null,
      lastRefreshInfo: t(lang).sampleLoaded,
    );
  }

  void clear(AppLang lang) {
    state = state.copyWith(
      localTags: const [],
      remoteTags: const [],
      localError: null,
      remoteError: null,
      query: '',
      filter: TagFilter.all,
      lastRefreshInfo: t(lang).cleared,
    );
  }

  void setQuery(String q) => state = state.copyWith(query: q);

  void setSort(TagSortMode m) => state = state.copyWith(sortMode: m);

  void setFilter(TagFilter f) => state = state.copyWith(filter: f);
}
