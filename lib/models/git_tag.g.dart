// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'git_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GitTag _$GitTagFromJson(Map<String, dynamic> json) => _GitTag(
  name: json['name'] as String,
  commitSha: json['commitSha'] as String?,
  tagObjectSha: json['tagObjectSha'] as String?,
  isAnnotated: json['isAnnotated'] as bool?,
  tagger: json['tagger'] as String?,
  tagDate: json['tagDate'] as String?,
  tagMessage: json['tagMessage'] as String?,
  commitAuthor: json['commitAuthor'] as String?,
  commitDate: json['commitDate'] as String?,
  commitSubject: json['commitSubject'] as String?,
  commitBody: json['commitBody'] as String?,
  source:
      $enumDecodeNullable(_$TagSourceEnumMap, json['source']) ??
      TagSource.local,
);

Map<String, dynamic> _$GitTagToJson(_GitTag instance) => <String, dynamic>{
  'name': instance.name,
  'commitSha': instance.commitSha,
  'tagObjectSha': instance.tagObjectSha,
  'isAnnotated': instance.isAnnotated,
  'tagger': instance.tagger,
  'tagDate': instance.tagDate,
  'tagMessage': instance.tagMessage,
  'commitAuthor': instance.commitAuthor,
  'commitDate': instance.commitDate,
  'commitSubject': instance.commitSubject,
  'commitBody': instance.commitBody,
  'source': _$TagSourceEnumMap[instance.source]!,
};

const _$TagSourceEnumMap = {
  TagSource.local: 'local',
  TagSource.remote: 'remote',
  TagSource.sample: 'sample',
};

_TagCompareItem _$TagCompareItemFromJson(Map<String, dynamic> json) =>
    _TagCompareItem(
      name: json['name'] as String,
      local: json['local'] == null
          ? null
          : GitTag.fromJson(json['local'] as Map<String, dynamic>),
      remote: json['remote'] == null
          ? null
          : GitTag.fromJson(json['remote'] as Map<String, dynamic>),
      status: $enumDecode(_$TagSyncStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$TagCompareItemToJson(_TagCompareItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'local': instance.local,
      'remote': instance.remote,
      'status': _$TagSyncStatusEnumMap[instance.status]!,
    };

const _$TagSyncStatusEnumMap = {
  TagSyncStatus.synced: 'synced',
  TagSyncStatus.onlyLocal: 'onlyLocal',
  TagSyncStatus.onlyRemote: 'onlyRemote',
  TagSyncStatus.diverged: 'diverged',
};

_TagStats _$TagStatsFromJson(Map<String, dynamic> json) => _TagStats(
  localCount: (json['localCount'] as num?)?.toInt() ?? 0,
  remoteCount: (json['remoteCount'] as num?)?.toInt() ?? 0,
  syncedCount: (json['syncedCount'] as num?)?.toInt() ?? 0,
  onlyLocalCount: (json['onlyLocalCount'] as num?)?.toInt() ?? 0,
  onlyRemoteCount: (json['onlyRemoteCount'] as num?)?.toInt() ?? 0,
  divergedCount: (json['divergedCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TagStatsToJson(_TagStats instance) => <String, dynamic>{
  'localCount': instance.localCount,
  'remoteCount': instance.remoteCount,
  'syncedCount': instance.syncedCount,
  'onlyLocalCount': instance.onlyLocalCount,
  'onlyRemoteCount': instance.onlyRemoteCount,
  'divergedCount': instance.divergedCount,
};
