import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:git_geek/features/tags/domain/semver.dart';
import 'package:git_geek/features/tags/domain/git_tag.dart';

part 'tags_state.freezed.dart';

/// Tags 页面状态（Freezed，不手写 copyWith）。
@freezed
abstract class TagsState with _$TagsState {
  const factory TagsState({
    @Default([]) List<GitTag> localTags,
    @Default([]) List<GitTag> remoteTags,
    @Default('') String query,
    @Default(TagSortMode.semverDesc) TagSortMode sortMode,
    @Default(TagFilter.all) TagFilter filter,
    @Default(false) bool isLoadingLocal,
    @Default(false) bool isLoadingRemote,
    String? localError,
    String? remoteError,
    @Default('') String lastRefreshInfo,
    @Default(false) bool remoteFromCache,
  }) = _TagsState;
}

/// Tags 派生视图：合并对比、统计、过滤排序后的可见列表。
extension TagsStateX on TagsState {
  List<TagCompareItem> get allCompare =>
      buildCompareItems(localTags, remoteTags);

  TagStats get stats => calcStats(allCompare);

  List<TagCompareItem> get visibleCompare => allCompare
      .filterByStatus(filter)
      .filterByQuery(query)
      .sortedByMode(sortMode);

  List<GitTag> get visibleLocal =>
      localTags.filterByQuery(query).sortedByMode(sortMode);

  List<GitTag> get visibleRemote =>
      remoteTags.filterByQuery(query).sortedByMode(sortMode);

  bool get isLoading => isLoadingLocal || isLoadingRemote;
}
