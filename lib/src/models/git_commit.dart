import 'package:git_geek/src/l10n/strings.dart';

/// 一条提交记录
class GitCommit {
  final String sha;
  final List<String> parents;
  final String? author;
  final String? date;
  final String? refs;
  final List<String> tags;
  final String? subject;
  final String? body;
  final List<SubmoduleChange> submoduleChanges;

  const GitCommit({
    required this.sha,
    this.parents = const [],
    this.author,
    this.date,
    this.refs,
    this.tags = const [],
    this.subject,
    this.body,
    this.submoduleChanges = const [],
  });

  String get shortSha => sha.length <= 8 ? sha : sha.substring(0, 8);

  List<String> get nonTagRefs {
    final r = refs;
    if (r == null || r.trim().isEmpty) return const [];
    return r
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('tag: '))
        .toList();
  }

  GitCommit copyWith({
    String? sha,
    List<String>? parents,
    String? author,
    String? date,
    String? refs,
    List<String>? tags,
    String? subject,
    String? body,
    List<SubmoduleChange>? submoduleChanges,
  }) {
    return GitCommit(
      sha: sha ?? this.sha,
      parents: parents ?? this.parents,
      author: author ?? this.author,
      date: date ?? this.date,
      refs: refs ?? this.refs,
      tags: tags ?? this.tags,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      submoduleChanges: submoduleChanges ?? this.submoduleChanges,
    );
  }
}

class GitBranch {
  final String name;
  final bool isCurrent;

  const GitBranch({required this.name, this.isCurrent = false});

  GitBranch copyWith({String? name, bool? isCurrent}) =>
      GitBranch(name: name ?? this.name, isCurrent: isCurrent ?? this.isCurrent);
}

const String gitLogPasteCommandTemplate =
    'git log --topo-order -m --raw --no-abbrev --date=format:%Y-%m-%d %H:%M --format="===COMMIT===%nsha: %H%nparents: %P%nauthor: %an%ndate: %ad%nrefs: %D%nsubject: %s%n%b%n===END===" -n 500 [分支名]';

extension CommitQueryX on List<GitCommit> {
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

enum SubmoduleStatus { ok, uninitialized, modified, conflict }

extension SubmoduleStatusX on SubmoduleStatus {
  String label(AppLang lang) {
    final t = strings(lang);
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
class SubmoduleRecord {
  final String sha;
  final String? author;
  final String? date;
  final String? subject;
  final bool isMerge;

  const SubmoduleRecord({
    required this.sha,
    this.author,
    this.date,
    this.subject,
    this.isMerge = false,
  });
}

/// 主仓库某次提交里子模块指针的变化
class SubmoduleChange {
  final String path;
  final String? oldSha;
  final String? newSha;
  final String? oldAuthor;
  final String? oldDate;
  final String? oldSubject;
  final String? newAuthor;
  final String? newDate;
  final String? newSubject;
  final SubmoduleRecord? recordedBy;
  final SubmoduleRecord? actualSwitchBy;
  final bool resolvedInMerge;
  final bool silentlyDropped;
  final String? droppedSha;
  final String? droppedFromParent;

  const SubmoduleChange({
    required this.path,
    this.oldSha,
    this.newSha,
    this.oldAuthor,
    this.oldDate,
    this.oldSubject,
    this.newAuthor,
    this.newDate,
    this.newSubject,
    this.recordedBy,
    this.actualSwitchBy,
    this.resolvedInMerge = false,
    this.silentlyDropped = false,
    this.droppedSha,
    this.droppedFromParent,
  });

  static bool _isZero(String? s) =>
      s == null || s.isEmpty || s.split('').every((c) => c == '0');

  bool get isAdded => _isZero(oldSha) && !_isZero(newSha);
  bool get isRemoved => _isZero(newSha) && !_isZero(oldSha);

  SubmoduleChange copyWith({
    String? path,
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
    bool? resolvedInMerge,
    bool? silentlyDropped,
    String? droppedSha,
    String? droppedFromParent,
  }) {
    return SubmoduleChange(
      path: path ?? this.path,
      oldSha: oldSha ?? this.oldSha,
      newSha: newSha ?? this.newSha,
      oldAuthor: oldAuthor ?? this.oldAuthor,
      oldDate: oldDate ?? this.oldDate,
      oldSubject: oldSubject ?? this.oldSubject,
      newAuthor: newAuthor ?? this.newAuthor,
      newDate: newDate ?? this.newDate,
      newSubject: newSubject ?? this.newSubject,
      recordedBy: recordedBy ?? this.recordedBy,
      actualSwitchBy: actualSwitchBy ?? this.actualSwitchBy,
      resolvedInMerge: resolvedInMerge ?? this.resolvedInMerge,
      silentlyDropped: silentlyDropped ?? this.silentlyDropped,
      droppedSha: droppedSha ?? this.droppedSha,
      droppedFromParent: droppedFromParent ?? this.droppedFromParent,
    );
  }
}

class GitSubmodule {
  final String path;
  final String? sha;
  final String? branch;
  final SubmoduleStatus status;

  const GitSubmodule({
    required this.path,
    this.sha,
    this.branch,
    this.status = SubmoduleStatus.ok,
  });

  String? get shortSha =>
      sha == null ? null : (sha!.length <= 8 ? sha : sha!.substring(0, 8));

  String get displayName {
    final p =
        path.split('/').last.split('\\').last;
    return p.isEmpty ? path : p;
  }
}

/// 给每条子模块变化附上切换溯源信息（对标原 attachSubmoduleRecordInfo）
List<GitCommit> attachSubmoduleRecordInfo(
  List<GitCommit> commits, [
  List<GitCommit> extraHistory = const [],
]) {
  if (commits.isEmpty) return commits;
  final loadedShas = commits.map((e) => e.sha).toSet();
  final olderOnly = extraHistory.where((e) => !loadedShas.contains(e.sha)).toList();
  final lastSwitch = <String, GitCommit>{};
  final lastCarried = <String, GitCommit>{};
  String key(String path, String sha) => '$path\x00$sha';
  final perCommit = <String, List<SubmoduleChange>>{};
  final chain = [...olderOnly.reversed, ...commits.reversed];
  for (final c in chain) {
    final isMerge = c.parents.length > 1;
    final mapped = c.submoduleChanges.map((ch) {
      // 对标原版 takeIf { isNotBlank }：判空用 trim，但 key 用原值
      final rawOld = ch.oldSha;
      final old = (rawOld != null && rawOld.trim().isNotEmpty) ? rawOld : null;
      final setter = old == null
          ? null
          : (lastCarried[key(ch.path, old)] ?? lastSwitch[key(ch.path, old)]);
      // 对标原版 ch.copy(recordedBy = setter?.let {...})：找不到时清零为 null，
      // copyWith 的 ?? 语义做不到清零，这里直接构造
      SubmoduleChange out;
      if (setter == null) {
        out = SubmoduleChange(
          path: ch.path,
          oldSha: ch.oldSha,
          newSha: ch.newSha,
          oldAuthor: ch.oldAuthor,
          oldDate: ch.oldDate,
          oldSubject: ch.oldSubject,
          newAuthor: ch.newAuthor,
          newDate: ch.newDate,
          newSubject: ch.newSubject,
          recordedBy: null,
          actualSwitchBy: ch.actualSwitchBy,
          resolvedInMerge: ch.resolvedInMerge,
          silentlyDropped: ch.silentlyDropped,
          droppedSha: ch.droppedSha,
          droppedFromParent: ch.droppedFromParent,
        );
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
        // 对标原版 newSha?.let：原值直接登记（含空串，查表时按 isNotBlank 过滤）
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
    // 内容等价检查：recordedBy/actual 决定是否重建
    return c.copyWith(submoduleChanges: mapped);
  }).toList();
}
