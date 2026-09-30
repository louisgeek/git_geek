/// 远程 git URL 识别（纯 Dart）
class GitUrlDetector {
  // 标准 URL 形式：scheme:// 开头。
  static final RegExp _urlRegex =
      RegExp(r'^(https?|ssh|git|ftps?)://', caseSensitive: false);
  // scp 形式：user@host:path。
  static final RegExp _scpRegex = RegExp(r'^[\w.\-]+@[\w.\-]+:.+');

  /// 是否为远程地址：本地路径返回 false。
  static bool isRemoteUrl(String s) {
    final t = s.trim();
    if (t.isEmpty) return false;
    return _urlRegex.hasMatch(t) || _scpRegex.hasMatch(t);
  }
}
