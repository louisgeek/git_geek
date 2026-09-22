import 'package:git_geek/src/models/git_commit.dart';

/// 提交记录解析器（对标原 GitLogParser）
class GitLogParser {
  static List<GitCommit> parse(String raw) {
    final lines = raw.split('\n');
    final out = <GitCommit>[];
    var i = 0;
    while (i < lines.length) {
      if (lines[i].trim() != '===COMMIT===') {
        i++;
        continue;
      }
      i++;
      var sha = '';
      var parents = '';
      var author = '';
      var date = '';
      var refs = '';
      var subject = '';
      var parentsSeen = false;
      var subjectSeen = false;
      while (i < lines.length) {
        final line = lines[i];
        if (line.trim() == '===END===') break;
        if (line.startsWith('sha:') && sha.isEmpty) {
          sha = line.substring(4).trim();
          i++;
          continue;
        } else if (line.startsWith('parents:') && !parentsSeen) {
          parents = line.substring(8).trim();
          parentsSeen = true;
          i++;
          continue;
        } else if (line.startsWith('author:') && author.isEmpty) {
          author = line.substring(7).trim();
          i++;
          continue;
        } else if (line.startsWith('date:') && date.isEmpty) {
          date = line.substring(5).trim();
          i++;
          continue;
        } else if (line.startsWith('refs:') && refs.isEmpty) {
          refs = line.substring(5).trim();
          i++;
          continue;
        } else if (line.startsWith('subject:') && !subjectSeen) {
          subject = line.substring(8).trim();
          subjectSeen = true;
          i++;
          break;
        } else {
          break;
        }
      }
      final bodyLines = <String>[];
      while (i < lines.length && lines[i].trim() != '===END===') {
        bodyLines.add(lines[i]);
        i++;
      }
      if (i < lines.length) i++;
      final rawLines = <String>[];
      while (i < lines.length && lines[i].trim() != '===COMMIT===') {
        if (lines[i].startsWith(':')) rawLines.add(lines[i]);
        i++;
      }
      if (sha.isNotEmpty) {
        final changes = parseRawSubmodules(rawLines);
        final last = out.isEmpty ? null : out.last;
        if (last != null && last.sha == sha) {
          final byPath = <String, SubmoduleChange>{};
          for (final ch in [...last.submoduleChanges, ...changes]) {
            final prev = byPath[ch.path];
            if (prev == null) {
              byPath[ch.path] = ch;
            } else if (prev.oldSha != ch.oldSha) {
              byPath[ch.path] = prev.copyWith(resolvedInMerge: true);
            }
          }
          out[out.length - 1] =
              last.copyWith(submoduleChanges: byPath.values.toList());
        } else {
          out.add(GitCommit(
            sha: sha,
            parents: parents
                .split(RegExp(r'\s+'))
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            author: author.isEmpty ? null : author,
            date: date.isEmpty ? null : date,
            refs: refs.isEmpty ? null : refs,
            tags: extractTags(refs),
            subject: subject.isEmpty ? null : subject,
            body: bodyLines.join('\n').trim().isEmpty
                ? null
                : bodyLines.join('\n').trim(),
            submoduleChanges: changes,
          ));
        }
      }
    }
    return out;
  }

  static final RegExp _rawRe =
      RegExp(r'^:(\d{6}) (\d{6}) ([0-9a-f]+) ([0-9a-f]+) ([A-Z]\d*)\t(.*)$');
  static final RegExp _zeroRe = RegExp(r'^0+$');

  static List<SubmoduleChange> parseRawSubmodules(List<String> rawLines) {
    final out = <SubmoduleChange>[];
    for (final line in rawLines) {
      final m = _rawRe.firstMatch(line.trimRight());
      if (m == null) continue;
      final oldMode = m.group(1)!;
      final newMode = m.group(2)!;
      final oldSha = m.group(3)!;
      final newSha = m.group(4)!;
      final path0 = m.group(6)!;
      if (oldMode != '160000' && newMode != '160000') continue;
      final path = path0.split('\t').last.trim();
      if (path.isEmpty) continue;
      out.add(SubmoduleChange(
        path: path,
        oldSha: _zeroRe.hasMatch(oldSha) ? null : oldSha,
        newSha: _zeroRe.hasMatch(newSha) ? null : newSha,
      ));
    }
    final seen = <String>{};
    return out.where((e) => seen.add(e.path)).toList();
  }

  static List<String> extractTags(String refs) {
    if (refs.trim().isEmpty) return const [];
    return refs
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.startsWith('tag: '))
        .map((e) => e.substring(5).trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static List<GitBranch> parseBranches(String raw) {
    final out = <GitBranch>[];
    for (final line in raw.split('\n')) {
      if (line.trim().isEmpty) continue;
      final t = line.trim();
      if (t.contains('->')) continue;
      final isCurrent = t.startsWith('*');
      var name = t.replaceFirst(RegExp(r'^[\*\s]+'), '').trim();
      if (name.isEmpty) continue;
      if (name.startsWith('remotes/')) name = name.substring(8);
      if (name.isEmpty || name == 'HEAD') continue;
      final idx = out.indexWhere((e) => e.name == name);
      if (idx == -1) {
        out.add(GitBranch(name: name, isCurrent: isCurrent));
      } else if (isCurrent) {
        out[idx] = out[idx].copyWith(isCurrent: true);
      }
    }
    return out;
  }
}

/// `git submodule status` 解析（对标原 GitSubmoduleParser）
class GitSubmoduleParser {
  static List<GitSubmodule> parse(String raw) {
    final shaRegex = RegExp(r'[0-9a-fA-F]{4,40}');
    final out = <GitSubmodule>[];
    for (final rawLine in raw.split('\n')) {
      if (rawLine.trim().isEmpty) continue;
      if (rawLine.isEmpty) continue;
      final flag = rawLine[0];
      final rest = rawLine.substring(1).trim();
      if (rest.isEmpty) continue;
      final parts = rest.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      if (shaRegex.stringMatch(parts[0]) != parts[0]) continue;
      final path = parts[1].trim();
      if (path.isEmpty) continue;
      String? branch = parts.length > 2 ? parts.sublist(2).join(' ').trim() : null;
      if (branch != null) {
        if (branch.startsWith('(') && branch.endsWith(')')) {
          branch = branch.substring(1, branch.length - 1).trim();
        }
        if (branch.startsWith('heads/')) branch = branch.substring(6);
        if (branch.isEmpty) branch = null;
      }
      final status = switch (flag) {
        '-' => SubmoduleStatus.uninitialized,
        '+' => SubmoduleStatus.modified,
        'U' => SubmoduleStatus.conflict,
        _ => SubmoduleStatus.ok,
      };
      if (out.every((e) => e.path != path)) {
        out.add(GitSubmodule(
            path: path, sha: parts[0], branch: branch, status: status));
      }
    }
    return out;
  }
}

/// 提交分支线计算（对标原 CommitGraph；当前 UI 仅用 isMerge，保留数据供后续画线）
class CommitGraphRow {
  final int lane;
  final List<String?> before;
  final List<String?> after;
  final Set<int> endingLanes;
  final Set<int> startingLanes;
  final bool isTip;
  final bool isMerge;

  const CommitGraphRow({
    required this.lane,
    required this.before,
    required this.after,
    required this.endingLanes,
    required this.startingLanes,
    required this.isTip,
    required this.isMerge,
  });
}

class CommitGraph {
  final List<CommitGraphRow> rows;
  final int maxLanes;
  const CommitGraph(this.rows, this.maxLanes);
}

CommitGraph buildCommitGraph(List<GitCommit> commits) {
  final slots = <String?>[];
  var maxLanes = 0;
  final rows = <CommitGraphRow>[];
  for (final c in commits) {
    var idx = slots.indexOf(c.sha);
    final isTip = idx == -1;
    if (isTip) {
      idx = slots.indexWhere((e) => e == null);
      if (idx == -1) {
        slots.add(c.sha);
        idx = slots.length - 1;
      } else {
        slots[idx] = c.sha;
      }
    }
    final before = List<String?>.of(slots);
    final ending = <int>{};
    final starting = <int>{};
    final parents =
        c.parents.where((e) => e.trim().isNotEmpty).toSet().toList();
    if (parents.isEmpty) {
      slots[idx] = null;
    } else {
      final p0 = parents[0];
      final j0 = slots.indexOf(p0);
      if (j0 != -1 && j0 != idx) {
        ending.add(j0);
        slots[j0] = null;
      }
      slots[idx] = p0;
      for (final p in parents.skip(1)) {
        final j = slots.indexOf(p);
        if (j == -1) {
          var k = slots.indexWhere((e) => e == null);
          if (k == -1) {
            slots.add(p);
            k = slots.length - 1;
          } else {
            slots[k] = p;
          }
          starting.add(k);
        } else if (j != idx) {
          ending.add(j);
          slots[j] = null;
        }
      }
      if (!before.whereType<String>().contains(p0)) starting.add(idx);
    }
    if (slots.length > maxLanes) maxLanes = slots.length;
    rows.add(CommitGraphRow(
      lane: idx,
      before: before,
      after: List<String?>.of(slots),
      endingLanes: ending,
      startingLanes: starting,
      isTip: isTip,
      isMerge: parents.length > 1,
    ));
  }
  return CommitGraph(rows, maxLanes);
}
