import 'package:git_geek/src/l10n/strings.dart';

/// 单个 Git Tag。annotated tag 有 tag 对象 sha 与 commit sha 之分，必须区分保存。
class GitTag {
  final String name;
  final String? commitSha;
  final String? tagObjectSha;
  final bool? isAnnotated;
  final String? tagger;
  final String? tagDate;
  final String? tagMessage;
  final String? commitAuthor;
  final String? commitDate;
  final String? commitSubject;
  final String? commitBody;
  final TagSource source;

  const GitTag({
    required this.name,
    this.commitSha,
    this.tagObjectSha,
    this.isAnnotated,
    this.tagger,
    this.tagDate,
    this.tagMessage,
    this.commitAuthor,
    this.commitDate,
    this.commitSubject,
    this.commitBody,
    this.source = TagSource.local,
  });

  GitTag copyWith({
    String? name,
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
    TagSource? source,
  }) {
    return GitTag(
      name: name ?? this.name,
      commitSha: commitSha ?? this.commitSha,
      tagObjectSha: tagObjectSha ?? this.tagObjectSha,
      isAnnotated: isAnnotated ?? this.isAnnotated,
      tagger: tagger ?? this.tagger,
      tagDate: tagDate ?? this.tagDate,
      tagMessage: tagMessage ?? this.tagMessage,
      commitAuthor: commitAuthor ?? this.commitAuthor,
      commitDate: commitDate ?? this.commitDate,
      commitSubject: commitSubject ?? this.commitSubject,
      commitBody: commitBody ?? this.commitBody,
      source: source ?? this.source,
    );
  }
}

enum TagSource { local, remote, sample }

/// 本地 vs 远程对比状态
enum TagSyncStatus { synced, onlyLocal, onlyRemote, diverged }

extension TagSyncStatusX on TagSyncStatus {
  String label(AppLang lang) {
    final t = strings(lang);
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
class TagCompareItem {
  final String name;
  final GitTag? local;
  final GitTag? remote;
  final TagSyncStatus status;

  const TagCompareItem({
    required this.name,
    this.local,
    this.remote,
    required this.status,
  });
}

enum TagSortMode { semverDesc, semverAsc, nameAsc, nameDesc }

extension TagSortModeX on TagSortMode {
  String label(AppLang lang) {
    final t = strings(lang);
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
  String label(AppLang lang) {
    final t = strings(lang);
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

class TagStats {
  final int localCount;
  final int remoteCount;
  final int syncedCount;
  final int onlyLocalCount;
  final int onlyRemoteCount;
  final int divergedCount;

  const TagStats({
    this.localCount = 0,
    this.remoteCount = 0,
    this.syncedCount = 0,
    this.onlyLocalCount = 0,
    this.onlyRemoteCount = 0,
    this.divergedCount = 0,
  });
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
