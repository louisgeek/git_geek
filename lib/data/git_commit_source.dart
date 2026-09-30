import 'package:git_geek/core/result.dart';
import 'package:git_geek/data/git_runner.dart';
import 'package:git_geek/data/git_url.dart';
import 'package:git_geek/data/remote_repo.dart';
import 'package:git_geek/l10n/strings.dart';
import 'package:git_geek/logic/git_log_parser.dart';
import 'package:git_geek/models/git_commit.dart';

// git log 自定义格式：`%n` 换行，`===COMMIT===/===END===` 为提交边界。
const String _commitFmt =
    '===COMMIT===%nsha: %H%nparents: %P%nauthor: %an%ndate: %ad%nrefs: %D%nsubject: %s%n%b%n===END===';

/// 提交/分支/子模块数据源（实例类，构造注入 [GitRunner]，语言按调用透传 [AppLang]）。
/// 经 `features/commits/di/providers.dart` 装配进 `CommitsRepository`。
/// 唯一的静态方法是纯函数 [applyMergeDrift]（无 IO，可单测）。
class GitCommitDataSource {
  final GitRunner _runner;
  GitCommitDataSource(this._runner);

  /// 是否支持本地 git。
  bool get supportsNativeGit => _runner.supportsNativeGit;

  /// 拉取提交列表：topo 排序 + raw 子模块变更，再补详情与漂移检测。
  Future<Result<List<GitCommit>>> fetchCommits(
      String repoPath, String branch, int limit, AppLang lang) async {
    final tr = t(lang);
    if (!supportsNativeGit) {
      return Result.err(tr.platformUnsupported('Web'));
    }
    try {
      final dir = await _resolveRepo(repoPath, lang);
      // 条数钳制到 1~5000，防过大拖慢解析。
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
      final out = await _runner.run(dir, args);
      if (!out.ok) throw Exception(out.stderr);
      final parsed = GitLogParser.parse(out.stdout);
      final withSubjects = await enrichSubmoduleChanges(dir, parsed);
      final withDrift = await detectMergeSubmoduleDrift(dir, withSubjects);
      final withDriftEnriched = await enrichSubmoduleChanges(dir, withDrift);
      return Result.ok(await fillRecordGaps(
          dir, attachSubmoduleRecordInfo(withDriftEnriched)));
    } catch (e, st) {
      return Result.err(
        '${tr.commitsFail}: ${cleanError(e)} (${tr.dirName}=${repoPath.trim().isEmpty ? '.' : repoPath.trim()})',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// 拉取分支列表。
  Future<Result<List<GitBranch>>> fetchBranches(
      String repoPath, AppLang lang) async {
    final tr = t(lang);
    if (!supportsNativeGit) {
      return Result.err(tr.platformUnsupported('Web'));
    }
    try {
      final dir = await _resolveRepo(repoPath, lang);
      final out = await _runner
          .run(dir, ['branch', '-a', '--format=%(HEAD) %(refname:short)']);
      if (!out.ok) throw Exception(out.stderr);
      return Result.ok(GitLogParser.parseBranches(out.stdout));
    } catch (e, st) {
      return Result.err('${tr.branchesFail}: ${cleanError(e)}',
          cause: e, stackTrace: st);
    }
  }

  /// 拉取子模块现状。
  Future<Result<List<GitSubmodule>>> fetchSubmodules(
      String repoPath, AppLang lang) async {
    final tr = t(lang);
    if (!supportsNativeGit) {
      return Result.err(tr.platformUnsupported('Web'));
    }
    try {
      final dir = await _resolveRepo(repoPath, lang);
      final out = await _runner.run(dir, ['submodule', 'status']);
      if (!out.ok) throw Exception(out.stderr);
      return Result.ok(GitSubmoduleParser.parse(out.stdout));
    } catch (e, st) {
      return Result.err('${tr.submodulesFail}: ${cleanError(e)}',
          cause: e, stackTrace: st);
    }
  }

  /// 拉取远端地址。
  Future<Result<String>> fetchRemoteUrl(
      String repoPath, String remote, AppLang lang) async {
    final tr = t(lang);
    if (!supportsNativeGit) return Result.err(tr.platformUnsupported('Web'));
    try {
      final dir = await _resolveRepo(repoPath, lang);
      final out = await _runner.run(
          dir, ['remote', 'get-url', remote.trim().isEmpty ? 'origin' : remote.trim()]);
      if (!out.ok) throw Exception(out.stderr);
      return Result.ok(out.stdout.trim());
    } catch (e, st) {
      return Result.err('${tr.remoteUrlFail}: ${cleanError(e)}',
          cause: e, stackTrace: st);
    }
  }

  /// 拉取子模块当前分支：进子模块目录查当前分支。
  Future<Result<String>> fetchSubmoduleBranch(
      String repoPath, String subPath, AppLang lang) async {
    final tr = t(lang);
    if (!supportsNativeGit) return Result.err(tr.platformUnsupported('Web'));
    try {
      final dir = await _resolveRepo(repoPath, lang);
      final subDir = '$dir/$subPath';
      final out =
          await _runner.run(subDir, ['branch', '--show-current']);
      if (!out.ok) throw Exception(out.stderr);
      return Result.ok(out.stdout.trim());
    } catch (e, st) {
      return Result.err('${tr.submoduleBranchFail}: ${cleanError(e)}',
          cause: e, stackTrace: st);
    }
  }

  /// 回填子模块指针两侧 id 在子模块里的信息
  Future<List<GitCommit>> enrichSubmoduleChanges(
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
          // 缓存 key：路径 + NUL + sha，避免拼接冲突。
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

  /// 补检 merge 的子模块静默丢失
  Future<List<GitCommit>> detectMergeSubmoduleDrift(
      String workDir, List<GitCommit> commits) async {
    final merges = commits.where((e) => e.parents.length == 2).toList();
    if (merges.isEmpty) return commits;
    final resultMap = <String, List<SubmoduleChange>>{};
    for (final commit in merges) {
      final p1out = await _runner.run(workDir, [
        'diff-tree',
        '--no-commit-id',
        '-r',
        '--no-abbrev',
        commit.parents[0],
        commit.sha,
      ]);
      final p2out = await _runner.run(workDir, [
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
      final updated = applyMergeDrift(
        existing: commit.submoduleChanges,
        changesP1: changesP1,
        changesP2: changesP2,
        secondParentSha: commit.parents[1],
      );
      if (updated != null) resultMap[commit.sha] = updated;
    }
    if (resultMap.isEmpty) return commits;
    return commits
        .map((c) => resultMap.containsKey(c.sha)
            ? c.copyWith(submoduleChanges: resultMap[c.sha]!)
            : c)
        .toList();
  }

  /// 纯函数：根据双边 diff 判定静默丢失，无 IO，可单测。
  /// p1 无变化且 p2 有变化时视为丢弃 p2，返回更新后列表；无变化返回 null。
  static List<SubmoduleChange>? applyMergeDrift({
    required List<SubmoduleChange> existing,
    required List<SubmoduleChange> changesP1,
    required List<SubmoduleChange> changesP2,
    required String secondParentSha,
  }) {
    final allPaths = {
      ...changesP1.map((e) => e.path),
      ...changesP2.map((e) => e.path)
    };
    if (allPaths.isEmpty) return null;
    final p1Map = {for (final e in changesP1) e.path: e};
    final p2Map = {for (final e in changesP2) e.path: e};
    final current = {for (final e in existing) e.path: e};
    var changed = false;
    for (final path in allPaths) {
      final inP1 = p1Map[path];
      final inP2 = p2Map[path];
      if (inP1 != null && inP2 == null) {
        if (current.remove(path) != null) changed = true;
      } else if (inP1 == null && inP2 != null) {
        final droppedSha = inP2.oldSha;
        final ex = current[path];
        if (ex != null) {
          if (!ex.silentlyDropped) {
            current[path] = ex.copyWith(
              silentlyDropped: true,
              droppedSha: droppedSha,
              droppedFromParent: secondParentSha,
            );
            changed = true;
          }
        } else {
          current[path] = SubmoduleChange(
            path: path,
            oldSha: droppedSha,
            newSha: inP2.newSha,
            silentlyDropped: true,
            droppedSha: droppedSha,
            droppedFromParent: secondParentSha,
          );
          changed = true;
        }
      }
    }
    return changed ? current.values.toList() : null;
  }

  Future<Map<String, _MiniCommit>> _queryMiniCommits(
      String workDir, List<String> shas) async {
    final distinct =
        shas.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
    if (distinct.isEmpty) return {};
    final result = <String, _MiniCommit>{};
    // 每批 80 个 sha，避免单次参数过长；`<00>` 为字段分隔。
    for (var i = 0; i < distinct.length; i += 80) {
      final chunk = distinct.sublist(
          i, i + 80 > distinct.length ? distinct.length : i + 80);
      final out = await _runner.run(workDir, [
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
  Future<List<GitCommit>> fillRecordGaps(
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
      final out = await _runner.run(workDir, [
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

  Future<String> _resolveRepo(String repoPath, AppLang lang) async {
    final trimmed = repoPath.trim();
    if (GitUrlDetector.isRemoteUrl(trimmed)) {
      return (await RemoteRepoResolver.resolve(trimmed, lang,
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
