import 'package:git_geek/src/models/git_tag.dart';

/// 纯 Dart 解析器（对标原 GitTagParser）
class GitTagParser {
  static List<GitTag> parseLocal(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return const [];
    final lines =
        text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final looksLikeShowRef = lines.any((e) => e.contains('refs/tags/'));
    if (looksLikeShowRef) {
      return _parseShowRefLines(lines, TagSource.local);
    }
    return lines.toSet().map((e) => GitTag(name: e, source: TagSource.local)).toList();
  }

  static List<GitTag> parseRemote(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return const [];
    final lines =
        text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final looksLikeLsRemote =
        lines.any((e) => e.contains('refs/tags/') || e.contains('\t'));
    if (looksLikeLsRemote) {
      return _parseShowRefLines(lines, TagSource.remote);
    }
    return lines.toSet().map((e) => GitTag(name: e, source: TagSource.remote)).toList();
  }

  static List<GitTag> _parseShowRefLines(List<String> lines, TagSource source) {
    final peeled = <String, String>{};
    final plain = <String, String>{};
    for (final line in lines) {
      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      final sha = parts[0].trim();
      var ref = parts[1].trim();
      if (sha.length < 4) continue;
      if (!ref.contains('refs/tags/')) continue;
      ref = ref.substring(ref.indexOf('refs/tags/') + 'refs/tags/'.length);
      if (ref.isEmpty) continue;
      if (ref.endsWith('^{}')) {
        final name = ref.substring(0, ref.length - 3);
        if (name.isNotEmpty) peeled[name] = sha;
      } else {
        plain.putIfAbsent(ref, () => sha);
      }
    }
    final names = {...plain.keys, ...peeled.keys};
    final out = names.map((name) {
      final tagSha = plain[name];
      final commit = peeled[name] ?? tagSha;
      return GitTag(
        name: name,
        commitSha: commit,
        tagObjectSha: tagSha,
        source: source,
      );
    }).toList();
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  }
}
