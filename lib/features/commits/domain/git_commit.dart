// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';

part 'git_commit.freezed.dart';
part 'git_commit.g.dart';

/// 一条提交记录
@freezed
abstract class GitCommit with _$GitCommit {
  const factory GitCommit({
    required String sha,
    @Default([]) List<String> parents,
    String? author,
    String? date,
    String? refs,
    @Default([]) List<String> tags,
    String? subject,
    String? body,
    @Default([]) List<SubmoduleChange> submoduleChanges,
  }) = _GitCommit;

  factory GitCommit.fromJson(Map<String, dynamic> json) =>
      _$GitCommitFromJson(json);
}

/// 提交的便捷取值：短 sha 与非 tag 引用。
extension GitCommitX on GitCommit {
  /// 短 sha：超 8 位截前 8 位。
  String get shortSha => sha.length <= 8 ? sha : sha.substring(0, 8);

  /// 非 tag 引用：refs 按逗号切分后去掉 `tag: ` 片段。
  List<String> get nonTagRefs {
    final r = refs;
    if (r == null || r.trim().isEmpty) return const [];
    return r
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('tag: '))
        .toList();
  }
}

/// 本地分支：名 + 是否当前分支。
@freezed
abstract class GitBranch with _$GitBranch {
  const factory GitBranch({
    required String name,
    @Default(false) bool isCurrent,
  }) = _GitBranch;

  factory GitBranch.fromJson(Map<String, dynamic> json) =>
      _$GitBranchFromJson(json);
}

/// 提交列表的关键字过滤。
extension CommitQueryX on List<GitCommit> {
  /// 按关键字过滤提交：匹配 sha、主题、正文、作者、tag 及子模块变化。
  List<GitCommit> filterByQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return this;
    return where((c) {
      if (c.sha.toLowerCase().contains(q)) return true;
      if ((c.subject?.toLowerCase().contains(q) ?? false)) return true;
      if ((c.body?.toLowerCase().contains(q) ?? false)) return true;
      if ((c.author?.toLowerCase().contains(q) ?? false)) return true;
      if (c.tags.any((t) => t.toLowerCase().contains(q))) return true;
      return c.submoduleChanges.any((ch) =>
          ch.path.toLowerCase().contains(q) ||
          (ch.oldSubject?.toLowerCase().contains(q) ?? false) ||
          (ch.newSubject?.toLowerCase().contains(q) ?? false) ||
          (ch.oldAuthor?.toLowerCase().contains(q) ?? false) ||
          (ch.newAuthor?.toLowerCase().contains(q) ?? false));
    }).toList();
  }
}

// ---------------- Submodule ----------------

/// 子模块状态：正常、未初始化、有修改、冲突。
enum SubmoduleStatus { ok, uninitialized, modified, conflict }

/// 子模块状态的本地化文案。
extension SubmoduleStatusX on SubmoduleStatus {
  /// 取该状态的展示文案（正常返回空串）。
  String label(AppLocalizations t) {
    switch (this) {
      case SubmoduleStatus.ok:
        return '';
      case SubmoduleStatus.uninitialized:
        return t.subUninitialized;
      case SubmoduleStatus.modified:
        return t.subModified;
      case SubmoduleStatus.conflict:
        return t.subConflict;
    }
  }
}

/// 主仓库里上一次经手该 id 的提交
@freezed
abstract class SubmoduleRecord with _$SubmoduleRecord {
  const factory SubmoduleRecord({
    required String sha,
    String? author,
    String? date,
    String? subject,
    @Default(false) bool isMerge,
  }) = _SubmoduleRecord;

  factory SubmoduleRecord.fromJson(Map<String, dynamic> json) =>
      _$SubmoduleRecordFromJson(json);
}

/// 主仓库某次提交里子模块指针的变化
@freezed
abstract class SubmoduleChange with _$SubmoduleChange {
  const factory SubmoduleChange({
    required String path,
    String? oldSha,
    String? newSha,
    String? oldAuthor,
    String? oldDate,
    String? oldSubject,
    String? newAuthor,
    String? newDate,
    String? newSubject,
    SubmoduleRecord? recordedBy,
    SubmoduleRecord? actualSwitchBy,
    @Default(false) bool resolvedInMerge,
    @Default(false) bool silentlyDropped,
    String? droppedSha,
    String? droppedFromParent,
  }) = _SubmoduleChange;

  factory SubmoduleChange.fromJson(Map<String, dynamic> json) =>
      _$SubmoduleChangeFromJson(json);
}

/// 子模块指针变化的便捷判断。
extension SubmoduleChangeX on SubmoduleChange {
  // 全零 sha 视作空（新增/删除边界）。
  static bool _isZero(String? s) =>
      s == null || s.isEmpty || s.split('').every((c) => c == '0');

  /// 是否新增子模块：旧空新非空。
  bool get isAdded => _isZero(oldSha) && !_isZero(newSha);

  /// 是否删除子模块：新空旧非空。
  bool get isRemoved => _isZero(newSha) && !_isZero(oldSha);
}

/// 工作区子模块现状：路径、sha、分支及状态。
@freezed
abstract class GitSubmodule with _$GitSubmodule {
  const factory GitSubmodule({
    required String path,
    String? sha,
    String? branch,
    @Default(SubmoduleStatus.ok) SubmoduleStatus status,
  }) = _GitSubmodule;

  factory GitSubmodule.fromJson(Map<String, dynamic> json) =>
      _$GitSubmoduleFromJson(json);
}

/// 子模块的便捷取值：短 sha 与展示名。
extension GitSubmoduleX on GitSubmodule {
  /// 短 sha：超 8 位截前 8 位。
  String? get shortSha =>
      sha == null ? null : (sha!.length <= 8 ? sha : sha!.substring(0, 8));

  /// 展示名：取路径最后一段。
  String get displayName {
    final p = path.split('/').last.split('\\').last;
    return p.isEmpty ? path : p;
  }
}

/// 给每条子模块变化附上切换溯源信息
List<GitCommit> attachSubmoduleRecordInfo(
  List<GitCommit> commits, [
  List<GitCommit> extraHistory = const [],
]) {
  if (commits.isEmpty) return commits;
  final loadedShas = commits.map((e) => e.sha).toSet();
  final olderOnly =
      extraHistory.where((e) => !loadedShas.contains(e.sha)).toList();
  final lastSwitch = <String, GitCommit>{};
  final lastCarried = <String, GitCommit>{};
  // 缓存 key：路径 + NUL + sha，避免拼接冲突。
  String key(String path, String sha) => '$path\x00$sha';
  final perCommit = <String, List<SubmoduleChange>>{};
  final chain = [...olderOnly.reversed, ...commits.reversed];
  for (final c in chain) {
    final isMerge = c.parents.length > 1;
    final mapped = c.submoduleChanges.map((ch) {
      final rawOld = ch.oldSha;
      final old = (rawOld != null && rawOld.trim().isNotEmpty) ? rawOld : null;
      final setter = old == null
          ? null
          : (lastCarried[key(ch.path, old)] ?? lastSwitch[key(ch.path, old)]);
      // Freezed copyWith 支持显式置 null（sentinel），这里直接用 copyWith 清零即可。
      SubmoduleChange out;
      if (setter == null) {
        out = ch.copyWith(recordedBy: null);
      } else {
        out = ch.copyWith(
          recordedBy: SubmoduleRecord(
            sha: setter.sha,
            author: setter.author,
            date: setter.date,
            subject: setter.subject,
            isMerge: setter.parents.length > 1,
          ),
        );
      }
      if (isMerge) {
        final rawNew = ch.newSha;
        final n = (rawNew != null && rawNew.trim().isNotEmpty) ? rawNew : null;
        if (n != null) {
          final a = lastSwitch[key(ch.path, n)];
          if (a != null) {
            out = out.copyWith(
              actualSwitchBy: SubmoduleRecord(
                sha: a.sha,
                author: a.author,
                date: a.date,
                subject: a.subject,
                isMerge: a.parents.length > 1,
              ),
            );
          }
        }
      }
      return out;
    }).toList();
    perCommit[c.sha] = mapped;
    if (!isMerge) {
      for (final ch in c.submoduleChanges) {
        final n = ch.newSha;
        if (n != null) lastSwitch[key(ch.path, n)] = c;
      }
    } else {
      for (final ch in c.submoduleChanges) {
        final n = ch.newSha;
        if (n == null) continue;
        if (ch.resolvedInMerge) {
          lastSwitch[key(ch.path, n)] = c;
        } else {
          lastCarried[key(ch.path, n)] = c;
        }
      }
    }
  }
  return commits.map((c) {
    final mapped = perCommit[c.sha];
    if (mapped == null || identical(mapped, c.submoduleChanges)) return c;
    var same = mapped.length == c.submoduleChanges.length;
    if (same) {
      for (var i = 0; i < mapped.length; i++) {
        if (!identical(mapped[i], c.submoduleChanges[i])) {
          same = false;
          break;
        }
      }
    }
    return c.copyWith(submoduleChanges: mapped);
  }).toList();
}
