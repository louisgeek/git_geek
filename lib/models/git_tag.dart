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

enum TagSource { local, remote, sample }

/// 本地 vs 远程对比状态
enum TagSyncStatus { synced, onlyLocal, onlyRemote, diverged }

extension TagSyncStatusX on TagSyncStatus {
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

enum TagSortMode { semverDesc, semverAsc, nameAsc, nameDesc }

extension TagSortModeX on TagSortMode {
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

enum TagFilter { all, synced, onlyLocal, onlyRemote, diverged }

extension TagFilterX on TagFilter {
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
  final t = s?.trim().toLowerCase();
  return (t == null || t.isEmpty) ? null : t;
}

TagSyncStatus _comparePair(GitTag l, GitTag r) {
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
