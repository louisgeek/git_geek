import 'package:git_geek/core/storage/database.dart';
import 'package:git_geek/data/git_tag_source.dart';
import 'package:git_geek/data/remote_repo.dart';
import 'package:git_geek/l10n/strings.dart';
import 'package:git_geek/models/git_tag.dart';
import 'package:logger/logger.dart';

/// Tags 仓储：Notifier 只调这里，不直调 DataSource / Sembast。
/// 策略：本地 tags 走 git CLI 直读；远程 tags 写透 Sembast 做离线兜底。
/// 装配见 `features/tags/di/providers.dart`。
class TagsRepository {
  final AppDatabase _db;
  final Logger _log;
  final GitTagDataSource _ds;
  TagsRepository(this._db, this._log, this._ds);

  /// 把 repoPath+scope 解析成实际生效目录（远程 URL 会触发克隆/增量更新）。
  Future<String> resolveDir(String repoPath, String scope, AppLang lang) =>
      RemoteRepoResolver.resolveEffectiveDir(repoPath, scope, lang);

  Future<List<GitTag>> fetchLocalTags(String dir, AppLang lang) {
    return _ds.fetchLocalTags(dir, lang);
  }

  Future<List<GitTag>> fetchRemoteTags(
      String dir, String remote, AppLang lang) async {
    final tags = await _ds.fetchRemoteTags(dir, remote, lang);
    // 写透缓存：失败不影响主流程。
    try {
      await _db.saveRemoteTags(
        _cacheKey(dir, remote),
        tags
            .map(
              (t) => CachedTag(
                name: t.name,
                commitSha: t.commitSha,
                tagObjectSha: t.tagObjectSha,
              ),
            )
            .toList(),
      );
    } catch (e, st) {
      _log.w('remote tags 缓存写入失败，忽略不影响主流程', error: e, stackTrace: st);
    }
    return tags;
  }

  /// 离线兜底：无网/git 失败时读缓存（过期按未命中处理）。
  Future<List<GitTag>> cachedRemoteTags(
    String dir,
    String remote, {
    Duration maxAge = const Duration(days: 7),
  }) async {
    try {
      final cache = await _db.loadRemoteTags(
        _cacheKey(dir, remote),
        maxAge: maxAge,
      );
      return cache?.tags
              .map(
                (r) => GitTag(
                  name: r.name,
                  commitSha: r.commitSha,
                  tagObjectSha: r.tagObjectSha,
                  source: TagSource.remote,
                ),
              )
              .toList() ??
          const [];
    } catch (e, st) {
      _log.w('读缓存 remote tags 失败', error: e, stackTrace: st);
      return const [];
    }
  }

  String _cacheKey(String repoPath, String remote) =>
      '${repoPath.trim()}#$remote';
}
