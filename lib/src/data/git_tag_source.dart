import 'package:git_geek/src/data/git_runner.dart';
import 'package:git_geek/src/data/git_url.dart';
import 'package:git_geek/src/data/remote_repo.dart';
import 'package:git_geek/src/l10n/strings.dart';
import 'package:git_geek/src/logic/git_tag_parser.dart';
import 'package:git_geek/src/models/git_tag.dart';

AppLang _tagLang = AppLang.zh;
void setTagDataSourceLang(AppLang lang) => _tagLang = lang;
AppStrings get _t => strings(_tagLang);

class _TagRefInfo {
  final String objectType;
  final String tagger;
  final String tagDate;
  final String subject;
  final String body;
  const _TagRefInfo(this.objectType, this.tagger, this.tagDate, this.subject, this.body);
}

class _CommitInfo {
  final String author;
  final String date;
  final String subject;
  final String body;
  const _CommitInfo(this.author, this.date, this.subject, this.body);
}

/// tag 数据源（对标原 jvm GitTagDataSource）
class GitTagDataSource {
  static bool get supportsNativeGit => gitRunner.supportsNativeGit;

  static Future<List<GitTag>> fetchLocalTags(String repoPath) async {
    if (!supportsNativeGit) {
      throw Exception(_t.noNativeGit('Platform', _t.cmdTagLocal));
    }
    try {
      final dir = await _resolveRepo(repoPath);
      final showRef =
          await gitRunner.run(dir, ['show-ref', '-d', '--tags']);
      var parsed = <GitTag>[];
      if (showRef.ok) {
        final out = showRef.stdout.trim();
        if (out.isNotEmpty) parsed = GitTagParser.parseLocal(out);
      }
      final base = parsed.isNotEmpty
          ? parsed
          : GitTagParser.parseLocal(
              (await gitRunner.run(dir, ['tag', '-l'])).stdoutOrThrow());
      if (base.isEmpty) return base;
      return _enrichLocal(dir, base);
    } catch (e) {
      throw Exception('${_t.localTagsFail}: $e (${_t.dirName}=${_dirOrSelf(repoPath)})');
    }
  }

  static Future<List<GitTag>> fetchRemoteTags(
      String repoPath, String remote) async {
    if (!supportsNativeGit) {
      throw Exception(_t.noNativeGit('Platform', _t.cmdTagLocal));
    }
    try {
      final dir = await _resolveRepo(repoPath);
      final target = remote.trim().isEmpty ? 'origin' : remote.trim();
      final out = (await gitRunner.run(dir, ['ls-remote', '--tags', target]))
          .stdoutOrThrow();
      final parsed = GitTagParser.parseRemote(out);
      if (parsed.isEmpty) return parsed;
      return _enrichRemote(dir, parsed);
    } catch (e) {
      throw Exception('${_t.remoteTagsFail}: $e (remote=$remote)');
    }
  }

  static Future<List<GitTag>> _enrichLocal(
      String workDir, List<GitTag> tags) async {
    Map<String, _TagRefInfo> refs = {};
    Map<String, _CommitInfo> commits = {};
    try {
      refs = await _queryTagRefs(workDir);
    } catch (_) {}
    try {
      commits = await _queryCommits(
          workDir, tags.map((e) => e.commitSha).whereType<String>().toList());
    } catch (_) {}
    return tags.map((t) => _mergeEnrichment(t, refs[t.name], commits[t.commitSha])).toList();
  }

  static Future<List<GitTag>> _enrichRemote(
      String workDir, List<GitTag> tags) async {
    final shas =
        tags.map((e) => e.commitSha).whereType<String>().toSet().toList();
    var existing = shas;
    try {
      existing = await _filterExistingObjects(workDir, shas);
    } catch (_) {}
    Map<String, _CommitInfo> commits = {};
    try {
      commits = await _queryCommits(workDir, existing);
    } catch (_) {}
    return tags.map((tag) {
      final ci = commits[tag.commitSha];
      return tag.copyWith(
        commitAuthor: (ci?.author.isNotEmpty ?? false) ? ci!.author : tag.commitAuthor,
        commitDate: (ci?.date.isNotEmpty ?? false) ? ci!.date : tag.commitDate,
        commitSubject:
            (ci?.subject.isNotEmpty ?? false) ? ci!.subject : tag.commitSubject,
        commitBody: (ci?.body.isNotEmpty ?? false) ? ci!.body : tag.commitBody,
      );
    }).toList();
  }

  static Future<Map<String, _TagRefInfo>> _queryTagRefs(String workDir) async {
    final fmt =
        ['%(refname:short)', '%(objecttype)', '%(taggername)', '%(taggerdate:format:%Y-%m-%d %H:%M)', '%(contents:subject)', '%(contents:body)']
            .join('%x00') +
            '%x1e';
    final out = (await gitRunner.run(
            workDir, ['for-each-ref', '--format=$fmt', 'refs/tags']))
        .stdoutOrThrow();
    final map = <String, _TagRefInfo>{};
    for (final rec in out.split('\u001e')) {
      if (rec.trim().isEmpty) continue;
      final f = rec.split('\u0000');
      if (f.length < 6) continue;
      final name = f[0].trim();
      if (name.isEmpty) continue;
      map[name] = _TagRefInfo(
          f[1].trim(), f[2].trim(), f[3].trim(), f[4].trim(), f[5].trim());
    }
    return map;
  }

  static Future<Map<String, _CommitInfo>> _queryCommits(
      String workDir, List<String> shas) async {
    final distinct =
        shas.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
    if (distinct.isEmpty) return {};
    final result = <String, _CommitInfo>{};
    for (var i = 0; i < distinct.length; i += 80) {
      final chunk = distinct.sublist(
          i, i + 80 > distinct.length ? distinct.length : i + 80);
      final fmt =
          ['%H', '%an', '%ad', '%s', '%b'].join('%x00') + '%x1e';
      final out = await gitRunner.run(workDir, [
        'log',
        '--no-walk',
        '--date=format:%Y-%m-%d %H:%M',
        '--format=$fmt',
        ...chunk,
      ]);
      if (!out.ok) continue;
      for (final rec in out.stdout.split('\u001e')) {
        if (rec.trim().isEmpty) continue;
        final f = rec.split('\u0000');
        if (f.length < 5) continue;
        final sha = f[0].trim();
        if (sha.isEmpty) continue;
        result[sha] = _CommitInfo(
            f[1].trim(), f[2].trim(), f[3].trim(), f[4].trim());
      }
    }
    return result;
  }

  static Future<List<String>> _filterExistingObjects(
      String workDir, List<String> shas) async {
    if (shas.isEmpty) return [];
    try {
      // 对标原版 cat-file --batch-check：dart 侧无 stdin 批量通道，退化为逐个 cat-file -t；
      // 语义对标原版：成功路径返回实际存在的集合（可为空），异常才保守回退全量
      final existing = <String>[];
      for (final s in shas) {
        final r = await gitRunner.run(workDir, ['cat-file', '-t', s]);
        if (r.ok) existing.add(s);
      }
      return existing;
    } catch (_) {
      return shas;
    }
  }

  static GitTag _mergeEnrichment(
      GitTag tag, _TagRefInfo? ref, _CommitInfo? ci) {
    final annotated = ref?.objectType == 'tag';
    final tagMsg = (ref != null && annotated)
        ? _combineSubjectBody(ref.subject, ref.body)
        : null;
    return tag.copyWith(
      isAnnotated: ref != null ? annotated : tag.isAnnotated,
      tagger: (ref != null && annotated && ref.tagger.isNotEmpty)
          ? ref.tagger
          : tag.tagger,
      tagDate: (ref != null && annotated && ref.tagDate.isNotEmpty)
          ? ref.tagDate
          : tag.tagDate,
      tagMessage: tagMsg ?? tag.tagMessage,
      commitAuthor:
          (ci?.author.isNotEmpty ?? false) ? ci!.author : tag.commitAuthor,
      commitDate: (ci?.date.isNotEmpty ?? false) ? ci!.date : tag.commitDate,
      commitSubject:
          (ci?.subject.isNotEmpty ?? false) ? ci!.subject : tag.commitSubject,
      commitBody: (ci?.body.isNotEmpty ?? false) ? ci!.body : tag.commitBody,
    );
  }

  static String? _combineSubjectBody(String subject, String body) {
    final s = subject.trim();
    final b = body.trim();
    if (s.isEmpty && b.isEmpty) return null;
    if (b.isEmpty) return s;
    if (s.isEmpty) return b;
    return b.startsWith(s) ? b : '$s\n\n$b';
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

  static String _dirOrSelf(String repoPath) {
    final trimmed = repoPath.trim();
    return trimmed.isEmpty ? '.' : trimmed;
  }
}

extension _RunX on GitResult {
  String stdoutOrThrow() {
    if (!ok) throw Exception(stderr);
    return stdout;
  }
}
