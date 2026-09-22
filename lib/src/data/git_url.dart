/// 远程 git URL 识别（纯 Dart，对标原 GitUrlDetector）
class GitUrlDetector {
  static final RegExp _urlRegex =
      RegExp(r'^(https?|ssh|git|ftps?)://', caseSensitive: false);
  static final RegExp _scpRegex = RegExp(r'^[\w.\-]+@[\w.\-]+:.+');

  static bool isRemoteUrl(String s) {
    final t = s.trim();
    if (t.isEmpty) return false;
    return _urlRegex.hasMatch(t) || _scpRegex.hasMatch(t);
  }
}
