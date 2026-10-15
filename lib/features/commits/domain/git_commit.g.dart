// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'git_commit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GitCommit _$GitCommitFromJson(Map<String, dynamic> json) => _GitCommit(
  sha: json['sha'] as String,
  parents:
      (json['parents'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  author: json['author'] as String?,
  date: json['date'] as String?,
  refs: json['refs'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  subject: json['subject'] as String?,
  body: json['body'] as String?,
  submoduleChanges:
      (json['submoduleChanges'] as List<dynamic>?)
          ?.map((e) => SubmoduleChange.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$GitCommitToJson(_GitCommit instance) =>
    <String, dynamic>{
      'sha': instance.sha,
      'parents': instance.parents,
      'author': instance.author,
      'date': instance.date,
      'refs': instance.refs,
      'tags': instance.tags,
      'subject': instance.subject,
      'body': instance.body,
      'submoduleChanges': instance.submoduleChanges,
    };

_GitBranch _$GitBranchFromJson(Map<String, dynamic> json) => _GitBranch(
  name: json['name'] as String,
  isCurrent: json['isCurrent'] as bool? ?? false,
);

Map<String, dynamic> _$GitBranchToJson(_GitBranch instance) =>
    <String, dynamic>{'name': instance.name, 'isCurrent': instance.isCurrent};

_SubmoduleRecord _$SubmoduleRecordFromJson(Map<String, dynamic> json) =>
    _SubmoduleRecord(
      sha: json['sha'] as String,
      author: json['author'] as String?,
      date: json['date'] as String?,
      subject: json['subject'] as String?,
      isMerge: json['isMerge'] as bool? ?? false,
    );

Map<String, dynamic> _$SubmoduleRecordToJson(_SubmoduleRecord instance) =>
    <String, dynamic>{
      'sha': instance.sha,
      'author': instance.author,
      'date': instance.date,
      'subject': instance.subject,
      'isMerge': instance.isMerge,
    };

_SubmoduleChange _$SubmoduleChangeFromJson(Map<String, dynamic> json) =>
    _SubmoduleChange(
      path: json['path'] as String,
      oldSha: json['oldSha'] as String?,
      newSha: json['newSha'] as String?,
      oldAuthor: json['oldAuthor'] as String?,
      oldDate: json['oldDate'] as String?,
      oldSubject: json['oldSubject'] as String?,
      newAuthor: json['newAuthor'] as String?,
      newDate: json['newDate'] as String?,
      newSubject: json['newSubject'] as String?,
      recordedBy: json['recordedBy'] == null
          ? null
          : SubmoduleRecord.fromJson(
              json['recordedBy'] as Map<String, dynamic>,
            ),
      actualSwitchBy: json['actualSwitchBy'] == null
          ? null
          : SubmoduleRecord.fromJson(
              json['actualSwitchBy'] as Map<String, dynamic>,
            ),
      resolvedInMerge: json['resolvedInMerge'] as bool? ?? false,
      silentlyDropped: json['silentlyDropped'] as bool? ?? false,
      droppedSha: json['droppedSha'] as String?,
      droppedFromParent: json['droppedFromParent'] as String?,
    );

Map<String, dynamic> _$SubmoduleChangeToJson(_SubmoduleChange instance) =>
    <String, dynamic>{
      'path': instance.path,
      'oldSha': instance.oldSha,
      'newSha': instance.newSha,
      'oldAuthor': instance.oldAuthor,
      'oldDate': instance.oldDate,
      'oldSubject': instance.oldSubject,
      'newAuthor': instance.newAuthor,
      'newDate': instance.newDate,
      'newSubject': instance.newSubject,
      'recordedBy': instance.recordedBy,
      'actualSwitchBy': instance.actualSwitchBy,
      'resolvedInMerge': instance.resolvedInMerge,
      'silentlyDropped': instance.silentlyDropped,
      'droppedSha': instance.droppedSha,
      'droppedFromParent': instance.droppedFromParent,
    };

_GitSubmodule _$GitSubmoduleFromJson(Map<String, dynamic> json) =>
    _GitSubmodule(
      path: json['path'] as String,
      sha: json['sha'] as String?,
      branch: json['branch'] as String?,
      status:
          $enumDecodeNullable(_$SubmoduleStatusEnumMap, json['status']) ??
          SubmoduleStatus.ok,
    );

Map<String, dynamic> _$GitSubmoduleToJson(_GitSubmodule instance) =>
    <String, dynamic>{
      'path': instance.path,
      'sha': instance.sha,
      'branch': instance.branch,
      'status': _$SubmoduleStatusEnumMap[instance.status]!,
    };

const _$SubmoduleStatusEnumMap = {
  SubmoduleStatus.ok: 'ok',
  SubmoduleStatus.uninitialized: 'uninitialized',
  SubmoduleStatus.modified: 'modified',
  SubmoduleStatus.conflict: 'conflict',
};
