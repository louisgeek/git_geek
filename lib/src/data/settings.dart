import 'package:shared_preferences/shared_preferences.dart';

/// 仓库配置持久化（对标原 GitTagSettings；桌面/移动落盘，Web 用内存兜底由插件处理）
class GitTagSettings {
  static const _kRepoPath = 'gitgeek.repoPath';
  static const _kRemote = 'gitgeek.remote';
  static const _kLang = 'gitgeek.lang';

  static SharedPreferences? _prefs;

  static Future<void> ensureInit() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String loadRepoPath() => _prefs?.getString(_kRepoPath) ?? '';
  static String loadRemote() => _prefs?.getString(_kRemote) ?? '';
  static String loadLang() => _prefs?.getString(_kLang) ?? '';
  static Future<void> saveRepoPath(String v) async =>
      _prefs?.setString(_kRepoPath, v);
  static Future<void> saveRemote(String v) async =>
      _prefs?.setString(_kRemote, v);
  static Future<void> saveLang(String v) async =>
      _prefs?.setString(_kLang, v);
}
