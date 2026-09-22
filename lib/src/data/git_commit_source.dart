import 'package:git_geek/src/data/git_runner.dart';
import 'package:git_geek/src/data/git_url.dart';
import 'package:git_geek/src/data/remote_repo.dart';
import 'package:git_geek/src/l10n/strings.dart';
import 'package:git_geek/src/logic/git_log_parser.dart';
import 'package:git_geek/src/models/git_commit.dart';

AppLang _commitLang = AppLang.zh;
void setCommitDataSourceLang(AppLang lang) => _commitLang = lang;
AppStrings get _t => strings(_commitLang);

const String _commitFmt =
    '===COMMIT===%nsha: %H%nparents: %P%nauthor: %an%ndate: %ad%nrefs: %D%nsubject: %s%n%b%n===END===';

/// 提交/分支/子模块数据源（对标原 jvm GitCommitDataSource）
class GitCommitDataSource {
  static Future<List<GitCommit>> fetchCommits(
      String repoPath, String branch, int limit) async {
    if (!supportsNativeGit) {
      throw Exception(_t.noNativeGit('Platform', _t.cmdLog));
    }
    try {
      final dir = await _resolveRepo(repoPath);
      final n = limit.clamp(1, 5000);
      final args = [
        'log',
        '--topo-order',
        '-m',
        '--raw',
        '--no-abbrev',
        '--date=format:%Y-%m-%d %H:%M',
        '--format=$_commitFmt',
        '--max-count=$n',
        if (branch.trim().isNotEmpty) branch.trim(),
      ];
      final out = await gitRunner.run(dir, args);
      if (!out.ok) throw Exception(out.stderr);
      final parsed = GitLogParser.parse(out.stdout);
      final withSubjects = await enrichSubmoduleChanges(dir, parsed);
      final withDrift = await detectMergeSubmoduleDrift(dir, withSubjects);
      final withDriftEnriched = await enrichSubmoduleChanges(dir, withDrift);
      return fillRecordGaps(dir, attachSubmoduleRecordInfo(withDriftEnriched));
    } catch (e) {
      throw Exception(
          '${_t.commitsFail}: $e (${_t.dirName}=${repoPath.trim().isEmpty ? '.' : repoPath.trim()})');
    }
  }

  static Future<List<GitBranch>> fetchBranches(String repoPath) async {
    if (!supportsNativeGit) {
      throw Exception(_t.noNativeGit('Platform', '`git branch -a`'));
    }
    try {
      final dir = await _resolveRepo(repoPath);
      final out = await gitRunner
          .run(dir, ['branch', '-a', '--format=%(HEAD) %(refname:short)']);
      if (!out.ok) throw Exception(out.stderr);
      return GitLogParser.parseBranches(out.stdout);
    } catch (e) {
      throw Exception('${_t.branchesFail}: $e');
    }
  }

  static Future<List<GitSubmodule>> fetchSubmodules(String repoPath) async {
    if (!supportsNativeGit) {
      throw Exception(_t.noNativeGit('Platform', '`git submodule status`'));
    }
    try {
      final dir = await _resolveRepo(repoPath);
      final out = await gitRunner.run(dir, ['submodule', 'status']);
      if (!out.ok) throw Exception(out.stderr);
      return GitSubmoduleParser.parse(out.stdout);
    } catch (e) {
      throw Exception('${_t.submodulesFail}: $e');
    }
  }

  static Future<String> fetchRemoteUrl(
      String repoPath, String remote) async {
    if (!supportsNativeGit) throw Exception(_t.noNativeGit('Platform', 'remote'));
    try {
      final dir = await _resolveRepo(repoPath);
      final out = await gitRunner.run(
          dir, ['remote', 'get-url', remote.trim().isEmpty ? 'origin' : remote.trim()]);
      if (!out.ok) throw Exception(out.stderr);
      return out.stdout.trim();
    } catch (e) {
      throw Exception('${_t.remoteUrlFail}: $e');
    }
  }

  static Future<String> fetchSubmoduleBranch(
      String repoPath, String subPath) async {
    if (!supportsNativeGit) throw Exception(_t.noNativeGit('Platform', 'branch'));
    try {
      final dir = await _resolveRepo(repoPath);
      final subDir = '$dir/$subPath';
      final out =
          await gitRunner.run(subDir, ['branch', '--show-current']);
      if (!out.ok) throw Exception(out.stderr);
      return out.stdout.trim();
    } catch (e) {
      throw Exception('${_t.submoduleBranchFail}: $e');
    }
  }

  /// 回填子模块指针两侧 id 在子模块里的信息
  static Future<List<GitCommit>> enrichSubmoduleChanges(
      String workDir, List<GitCommit> commits) async {
    final wanted = <String, Set<String>>{};
    for (final c in commits) {
      for (final ch in c.submoduleChanges) {
        final set = wanted.putIfAbsent(ch.path, () => <String>{});
        if (ch.oldSha != null && ch.oldSha!.isNotEmpty) set.add(ch.oldSha!);
        if (ch.newSha != null && ch.newSha!.isNotEmpty) set.add(ch.newSha!);
      }
    }
    if (wanted.isEmpty) return commits;
    final infos = <String, _MiniCommit>{};
    for (final entry in wanted.entries) {
      try {
        final got = await _queryMiniCommits(
            '$workDir/${entry.key}', entry.value.toList());
        for (final e in got.entries) {
          infos['${entry.key}\x00${e.key}'] = e.value;
        }
      } catch (_) {}
    }
    if (infos.isEmpty) return commits;
    return commits.map((c) {
      if (c.submoduleChanges.isEmpty) return c;
      return c.copyWith(
          submoduleChanges: c.submoduleChanges.map((ch) {
        final old =
            ch.oldSha == null ? null : infos['${ch.path}\x00${ch.oldSha}'];
        final n =
            ch.newSha == null ? null : infos['${ch.path}\x00${ch.newSha}'];
        return ch.copyWith(
          oldAuthor: (old?.author.isNotEmpty ?? false) ? old!.author : ch.oldAuthor,
          oldDate: (old?.date.isNotEmpty ?? false) ? old!.date : ch.oldDate,
          oldSubject:
              (old?.subject.isNotEmpty ?? false) ? old!.subject : ch.oldSubject,
          newAuthor: (n?.author.isNotEmpty ?? false) ? n!.author : ch.newAuthor,
          newDate: (n?.date.isNotEmpty ?? false) ? n!.date : ch.newDate,
          newSubject:
              (n?.subject.isNotEmpty ?? false) ? n!.subject : ch.newSubject,
        );
      }).toList());
    }).toList();
  }

  /// 补检 merge 的子模块静默丢失（对标原 detectMergeSubmoduleDrift）
  static Future<List<GitCommit>> detectMergeSubmoduleDrift(
      String workDir, List<GitCommit> commits) async {
    final merges = commits.where((e) => e.parents.length == 2).toList();
    if (merges.isEmpty) return commits;
    final resultMap = <String, List<SubmoduleChange>>{};
    for (final commit in merges) {
      final p1out = await gitRunner.run(workDir, [
        'diff-tree',
        '--no-commit-id',
        '-r',
        '--no-abbrev',
        commit.parents[0],
        commit.sha,
      ]);
      final p2out = await gitRunner.run(workDir, [
        'diff-tree',
        '--no-commit-id',
        '-r',
        '--no-abbrev',
        commit.parents[1],
        commit.sha,
      ]);
      final rawP1 = p1out.ok
          ? p1out.stdout.split('\n').where((e) => e.startsWith(':')).toList()
          : <String>[];
      final rawP2 = p2out.ok
          ? p2out.stdout.split('\n').where((e) => e.startsWith(':')).toList()
          : <String>[];
      final changesP1 = GitLogParser.parseRawSubmodules(rawP1);
      final changesP2 = GitLogParser.parseRawSubmodules(rawP2);
      final allPaths = {...changesP1.map((e) => e.path), ...changesP2.map((e) => e.path)};
      if (allPaths.isEmpty) continue;
      final p1Map = {for (final e in changesP1) e.path: e};
      final p2Map = {for (final e in changesP2) e.path: e};
      final existing = {for (final e in commit.submoduleChanges) e.path: e};
      var changed = false;
      for (final path in allPaths) {
        final inP1 = p1Map[path];
        final inP2 = p2Map[path];
        if (inP1 != null && inP2 == null) {
          if (existing.remove(path) != null) changed = true;
        } else if (inP1 == null && inP2 != null) {
          final droppedSha = inP2.oldSha;
          final ex = existing[path];
          if (ex != null) {
            if (!ex.silentlyDropped) {
              existing[path] = ex.copyWith(
                silentlyDropped: true,
                droppedSha: droppedSha,
                droppedFromParent: commit.parents[1],
              );
              changed = true;
            }
          } else {
            existing[path] = SubmoduleChange(
              path: path,
              oldSha: droppedSha,
              newSha: inP2.newSha,
              silentlyDropped: true,
              droppedSha: droppedSha,
              droppedFromParent: commit.parents[1],
            );
            changed = true;
          }
        }
      }
      if (changed) resultMap[commit.sha] = existing.values.toList();
    }
    if (resultMap.isEmpty) return commits;
    return commits
        .map((c) => resultMap.containsKey(c.sha)
            ? c.copyWith(submoduleChanges: resultMap[c.sha]!)
            : c)
        .toList();
  }

  static Future<Map<String, _MiniCommit>> _queryMiniCommits(
      String workDir, List<String> shas) async {
    final distinct =
        shas.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
    if (distinct.isEmpty) return {};
    final result = <String, _MiniCommit>{};
    for (var i = 0; i < distinct.length; i += 80) {
      final chunk = distinct.sublist(
          i, i + 80 > distinct.length ? distinct.length : i + 80);
      final out = await gitRunner.run(workDir, [
        'log',
        '--no-walk',
        '--date=format:%Y-%m-%d %H:%M',
        '--format=%H<00>%an<00>%ad<00>%s',
        ...chunk,
      ]);
      if (!out.ok) continue;
      for (final line in out.stdout.split('\n')) {
        if (line.trim().isEmpty) continue;
        final f = line.split('<00>');
        if (f.length < 4) continue;
        final sha = f[0].trim();
        if (sha.isEmpty) continue;
        result[sha] =
            _MiniCommit(f[1].trim(), f[2].trim(), f[3].trim());
      }
    }
    return result;
  }

  /// 补查范围外的溯源提交
  static Future<List<GitCommit>> fillRecordGaps(
      String workDir, List<GitCommit> commits) async {
    final missing = commits
        .expand((c) => c.submoduleChanges
            .where((ch) {
              if (ch.silentlyDropped) return false;
              final needRecorded = (ch.oldSha?.isNotEmpty ?? false) &&
                  ch.recordedBy == null;
              final needActual = c.parents.length > 1 &&
                  ch.newSha != null &&
                  !ch.resolvedInMerge &&
                  ch.actualSwitchBy == null;
              return needRecorded || needActual;
            })
            .map((e) => e.path))
        .toSet()
        .toList();
    if (missing.isEmpty) return commits;
    final extra = <GitCommit>[];
    for (final path in missing) {
      final out = await gitRunner.run(workDir, [
        'log',
        '--topo-order',
        '-m',
        '--raw',
        '--no-abbrev',
        '--date=format:%Y-%m-%d %H:%M',
        '--format=$_commitFmt',
        '--',
        path,
      ]);
      if (!out.ok) continue;
      extra.addAll(GitLogParser.parse(out.stdout));
    }
    if (extra.isEmpty) return commits;
    return attachSubmoduleRecordInfo(commits, extra);
  }

  static Future<String> _resolveRepo(String repoPath) async {
    final trimmed = repoPath.trim();
    if (GitUrlDetector.isRemoteUrl(trimmed)) {
      return (await RemoteRepoResolver.resolve(trimmed,
              fetchIfCached: true))
          .path;
    }
    return trimmed.isEmpty ? '.' : trimmed;
  }
}

class _MiniCommit {
  final String author;
  final String date;
  final String subject;
  const _MiniCommit(this.author, this.date, this.subject);
}
