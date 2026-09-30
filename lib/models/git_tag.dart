// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';

part 'git_tag.freezed.dart';
part 'git_tag.g.dart';

/// 单个 Git Tag。annotated tag 有 tag 对象 sha 与 commit sha 之分，必须区分保存。
@freezed
abstract class GitTag with _$GitTag {
  const factory GitTag({
    required String name,
    String? commitSha,
    String? tagObjectSha,
    bool? isAnnotated,
    String? tagger,
    String? tagDate,
    String? tagMessage,
    String? commitAuthor,
    String? commitDate,
    String? commitSubject,
    String? commitBody,
    @Default(TagSource.local) TagSource source,
  }) = _GitTag;

  factory GitTag.fromJson(Map<String, dynamic> json) =>
      _$GitTagFromJson(json);
}

/// Tag 来源命名空间（与 git 概念一致）：本地 `refs/tags` 直读 vs `ls-remote` 远端结果。
enum TagSource { local, remote }

/// 本地 vs 远程对比状态
enum TagSyncStatus { synced, onlyLocal, onlyRemote, diverged }

/// 同步状态的本地化文案。
extension TagSyncStatusX on TagSyncStatus {
  /// 取该状态的展示文案。
  String label(AppLocalizations t) {
    switch (this) {
      case TagSyncStatus.synced:
        return t.statSynced;
      case TagSyncStatus.onlyLocal:
        return t.statOnlyLocal;
      case TagSyncStatus.onlyRemote:
        return t.statOnlyRemote;
      case TagSyncStatus.diverged:
        return t.diverged;
    }
  }
}

/// 合并后的一行对比项
@freezed
abstract class TagCompareItem with _$TagCompareItem {
  const factory TagCompareItem({
    required String name,
    GitTag? local,
    GitTag? remote,
    required TagSyncStatus status,
  }) = _TagCompareItem;

  factory TagCompareItem.fromJson(Map<String, dynamic> json) =>
      _$TagCompareItemFromJson(json);
}

/// Tag 排序模式：语义版本升/降序、名称升/降序。
enum TagSortMode { semverDesc, semverAsc, nameAsc, nameDesc }

/// 排序模式的本地化文案。
extension TagSortModeX on TagSortMode {
  /// 取该排序模式的展示文案。
  String label(AppLocalizations t) {
    switch (this) {
      case TagSortMode.semverDesc:
        return '${t.sortSemver} ↓';
      case TagSortMode.semverAsc:
        return '${t.sortSemver} ↑';
      case TagSortMode.nameAsc:
        return '${t.sortName} A→Z';
      case TagSortMode.nameDesc:
        return '${t.sortName} Z→A';
    }
  }
}

/// Tag 过滤条件：全部及各同步状态。
enum TagFilter { all, synced, onlyLocal, onlyRemote, diverged }

/// 过滤条件的本地化文案。
extension TagFilterX on TagFilter {
  /// 取该过滤条件的展示文案。
  String label(AppLocalizations t) {
    switch (this) {
      case TagFilter.all:
        return t.filterAll;
      case TagFilter.synced:
        return t.statSynced;
      case TagFilter.onlyLocal:
        return t.statOnlyLocal;
      case TagFilter.onlyRemote:
        return t.statOnlyRemote;
      case TagFilter.diverged:
        return t.diverged;
    }
  }
}

/// Tag 同步统计：本地/远程计数及各状态计数。
@freezed
abstract class TagStats with _$TagStats {
  const factory TagStats({
    @Default(0) int localCount,
    @Default(0) int remoteCount,
    @Default(0) int syncedCount,
    @Default(0) int onlyLocalCount,
    @Default(0) int onlyRemoteCount,
    @Default(0) int divergedCount,
  }) = _TagStats;

  factory TagStats.fromJson(Map<String, dynamic> json) =>
      _$TagStatsFromJson(json);
}

/// 合并本地与远程 tag 为对比项：同名配对，否则记为仅单侧。
List<TagCompareItem> buildCompareItems(
  List<GitTag> localTags,
  List<GitTag> remoteTags,
) {
  final localMap = {for (final t in localTags) t.name: t};
  final remoteMap = {for (final t in remoteTags) t.name: t};
  final allNames = {...localMap.keys, ...remoteMap.keys};
  return allNames.map((name) {
    final l = localMap[name];
    final r = remoteMap[name];
    final status = l != null && r != null
        ? _comparePair(l, r)
        : (l != null ? TagSyncStatus.onlyLocal : TagSyncStatus.onlyRemote);
    return TagCompareItem(name: name, local: l, remote: r, status: status);
  }).toList();
}

String? _normSha(String? s) {
  // sha 归一：去空格转小写，空值归 null 便于比较。
  final t = s?.trim().toLowerCase();
  return (t == null || t.isEmpty) ? null : t;
}

TagSyncStatus _comparePair(GitTag l, GitTag r) {
  // 附注 tag 优先比 tag 对象 sha，其次比提交 sha；轻量 tag 直接比提交 sha。
  final lTag = _normSha(l.tagObjectSha);
  final rTag = _normSha(r.tagObjectSha);
  if (lTag != null && rTag != null) {
    if (lTag == rTag) return TagSyncStatus.synced;
    final lCommit = _normSha(l.commitSha);
    final rCommit = _normSha(r.commitSha);
    if (lCommit != null && rCommit != null) {
      return lCommit == rCommit ? TagSyncStatus.synced : TagSyncStatus.diverged;
    }
    return TagSyncStatus.diverged;
  }
  final lCommit = _normSha(l.commitSha);
  final rCommit = _normSha(r.commitSha);
  if (lCommit == null || lCommit.isEmpty || rCommit == null || rCommit.isEmpty) {
    return TagSyncStatus.synced;
  }
  return lCommit == rCommit ? TagSyncStatus.synced : TagSyncStatus.diverged;
}

/// 按对比项统计各同步状态计数。
TagStats calcStats(List<TagCompareItem> items) => TagStats(
      localCount: items.where((e) => e.local != null).length,
      remoteCount: items.where((e) => e.remote != null).length,
      syncedCount: items.where((e) => e.status == TagSyncStatus.synced).length,
      onlyLocalCount:
          items.where((e) => e.status == TagSyncStatus.onlyLocal).length,
      onlyRemoteCount:
          items.where((e) => e.status == TagSyncStatus.onlyRemote).length,
      divergedCount:
          items.where((e) => e.status == TagSyncStatus.diverged).length,
    );
