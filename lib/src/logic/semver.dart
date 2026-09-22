import 'package:git_geek/src/models/git_tag.dart';

/// 语义版本比较（对标原 SemVerComparator）
class SemVerComparator {
  static int compare(String a, String b) {
    final na = _normalize(a);
    final nb = _normalize(b);
    final aIsVer = _isVersionLike(na);
    final bIsVer = _isVersionLike(nb);
    if (aIsVer && bIsVer) {
      final r = _compareVersion(na, nb);
      if (r != 0) return r;
    } else if (aIsVer != bIsVer) {
      return aIsVer ? -1 : 1;
    }
    return a.compareTo(b);
  }

  static int compareTag(GitTag a, GitTag b, TagSortMode mode) {
    final base = compare(a.name, b.name);
    switch (mode) {
      case TagSortMode.semverDesc:
        return -base;
      case TagSortMode.semverAsc:
        return base;
      case TagSortMode.nameAsc:
        return a.name.compareTo(b.name);
      case TagSortMode.nameDesc:
        return b.name.compareTo(a.name);
    }
  }

  static int compareItem(TagCompareItem a, TagCompareItem b, TagSortMode mode) {
    final base = compare(a.name, b.name);
    switch (mode) {
      case TagSortMode.semverDesc:
        return -base;
      case TagSortMode.semverAsc:
        return base;
      case TagSortMode.nameAsc:
        return a.name.compareTo(b.name);
      case TagSortMode.nameDesc:
        return b.name.compareTo(a.name);
    }
  }

  static String _normalize(String s) {
    var t = s.trim();
    if ((t.startsWith('v') || t.startsWith('V')) &&
        t.length > 1 &&
        _isDigit(t[1])) {
      t = t.substring(1);
    }
    return t;
  }

  static bool _isDigit(String c) {
    final u = c.codeUnitAt(0);
    return u >= 48 && u <= 57;
  }

  static bool _isVersionLike(String s) {
    if (s.isEmpty) return false;
    if (!_isDigit(s[0])) return false;
    return s.split('').any(_isDigit);
  }

  static int _compareVersion(String a, String b) {
    final ap = _splitPreRelease(a);
    final bp = _splitPreRelease(b);
    final r = _compareDotParts(ap.$1, bp.$1);
    if (r != 0) return r;
    if (ap.$2 == null && bp.$2 == null) return 0;
    if (ap.$2 == null) return 1;
    if (bp.$2 == null) return -1;
    return _compareDotParts(ap.$2!, bp.$2!);
  }

  static (String, String?) _splitPreRelease(String s) {
    final idx = s.indexOf('-');
    if (idx < 0) return (s, null);
    return (s.substring(0, idx), s.substring(idx + 1));
  }

  static int _compareDotParts(String a, String b) {
    final pa = a.split(RegExp(r'[._+/]'));
    final pb = b.split(RegExp(r'[._+/]'));
    final n = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < n; i++) {
      final xa = i < pa.length ? pa[i] : '0';
      final xb = i < pb.length ? pb[i] : '0';
      final r = _compareSinglePart(xa, xb);
      if (r != 0) return r;
    }
    return 0;
  }

  static int _compareSinglePart(String a, String b) {
    final aNum = int.tryParse(a);
    final bNum = int.tryParse(b);
    if (aNum != null && bNum != null) return aNum.compareTo(bNum);
    final ta = _tokenize(a);
    final tb = _tokenize(b);
    final n = ta.length > tb.length ? ta.length : tb.length;
    for (var i = 0; i < n; i++) {
      final xa = i < ta.length ? ta[i] : '';
      final xb = i < tb.length ? tb[i] : '';
      final xn = int.tryParse(xa);
      final yn = int.tryParse(xb);
      final r = (xn != null && yn != null)
          ? xn.compareTo(yn)
          : xa.compareTo(xb);
      if (r != 0) return r;
    }
    return 0;
  }

  static List<String> _tokenize(String s) {
    if (s.isEmpty) return const [];
    final out = <String>[];
    final cur = StringBuffer();
    var curIsDigit = _isDigit(s[0]);
    for (var i = 0; i < s.length; i++) {
      final isD = _isDigit(s[i]);
      if (isD == curIsDigit) {
        cur.write(s[i]);
      } else {
        out.add(cur.toString());
        cur.clear();
        cur.write(s[i]);
        curIsDigit = isD;
      }
    }
    out.add(cur.toString());
    return out;
  }
}

extension CompareQueryX on List<TagCompareItem> {
  List<TagCompareItem> filterByQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return this;
    return where((it) =>
        it.name.toLowerCase().contains(q) ||
        _matchTag(it.local, q) ||
        _matchTag(it.remote, q)).toList();
  }

  List<TagCompareItem> filterByStatus(TagFilter filter) {
    if (filter == TagFilter.all) return this;
    return where((it) {
      switch (filter) {
        case TagFilter.synced:
          return it.status == TagSyncStatus.synced;
        case TagFilter.onlyLocal:
          return it.status == TagSyncStatus.onlyLocal;
        case TagFilter.onlyRemote:
          return it.status == TagSyncStatus.onlyRemote;
        case TagFilter.diverged:
          return it.status == TagSyncStatus.diverged;
        case TagFilter.all:
          return true;
      }
    }).toList();
  }

  List<TagCompareItem> sortedByMode(TagSortMode mode) {
    final list = toList();
    list.sort((a, b) => SemVerComparator.compareItem(a, b, mode));
    return list;
  }
}

bool _matchTag(GitTag? t, String q) {
  if (t == null) return false;
  return (t.commitSha?.toLowerCase().contains(q) ?? false) ||
      (t.commitSubject?.toLowerCase().contains(q) ?? false) ||
      (t.commitBody?.toLowerCase().contains(q) ?? false) ||
      (t.commitAuthor?.toLowerCase().contains(q) ?? false) ||
      (t.tagMessage?.toLowerCase().contains(q) ?? false) ||
      (t.tagger?.toLowerCase().contains(q) ?? false);
}

extension GitTagListX on List<GitTag> {
  List<GitTag> sortedByMode(TagSortMode mode) {
    final list = toList();
    list.sort((a, b) => SemVerComparator.compareTag(a, b, mode));
    return list;
  }

  List<GitTag> filterByQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return this;
    return where((it) =>
        it.name.toLowerCase().contains(q) ||
        (it.commitSha?.toLowerCase().contains(q) ?? false) ||
        (it.commitSubject?.toLowerCase().contains(q) ?? false) ||
        (it.commitBody?.toLowerCase().contains(q) ?? false) ||
        (it.commitAuthor?.toLowerCase().contains(q) ?? false) ||
        (it.tagMessage?.toLowerCase().contains(q) ?? false)).toList();
  }
}
