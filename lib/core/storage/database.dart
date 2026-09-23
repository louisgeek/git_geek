import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

/// 离线缓存：remote tags 兜底，一个仓库（repoPath + remote）存一条文档。
/// 简单 kv（repoPath/remote/lang）继续走 SharedPreferences，别进 DB。
///
/// 文档结构 `remote_tags`：record key = 仓库 key ->
/// `{tags: [{name, commitSha, tagObjectSha}], updatedAt: millis}`。
/// 写是单条 put（原子整体替换），读是单条 get，不做关系查询。
class CachedTag {
  final String name;
  final String? commitSha;
  final String? tagObjectSha;

  const CachedTag({
    required this.name,
    this.commitSha,
    this.tagObjectSha,
  });

  Map<String, Object?> toMap() => {
        'name': name,
        'commitSha': commitSha,
        'tagObjectSha': tagObjectSha,
      };

  factory CachedTag.fromMap(Map<String, Object?> map) => CachedTag(
        name: (map['name'] ?? '') as String,
        commitSha: map['commitSha'] as String?,
        tagObjectSha: map['tagObjectSha'] as String?,
      );
}

/// 某仓库的缓存快照：读不到记录时返回 null（调用方视同未命中）。
class RemoteTagsCache {
  final List<CachedTag> tags;
  final DateTime updatedAt;

  const RemoteTagsCache({required this.tags, required this.updatedAt});
}

class AppDatabase {
  final Future<Database> _dbFuture;

  AppDatabase() : _dbFuture = _openFileDb();

  /// 测试/预览用内存库，避免碰文件系统。
  /// 每个实例用独立 factory，互不污染。
  AppDatabase.memory()
      : _dbFuture = newDatabaseFactoryMemory().openDatabase('gitgeek_test');

  static final StoreRef<String, Map<String, Object?>> _tagsStore =
      stringMapStoreFactory.store('remote_tags');

  /// 写透缓存：整体替换该仓库的 tags。
  Future<void> saveRemoteTags(String key, List<CachedTag> tags) async {
    final db = await _dbFuture;
    await _tagsStore.record(key).put(db, {
      'tags': tags.map((t) => t.toMap()).toList(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 读缓存：无记录或超过 [maxAge]（默认 7 天）返回 null（调用方视同未命中）。
  Future<RemoteTagsCache?> loadRemoteTags(
    String key, {
    Duration maxAge = const Duration(days: 7),
  }) async {
    final db = await _dbFuture;
    final map = await _tagsStore.record(key).get(db);
    if (map == null) return null;
    final tags = <CachedTag>[];
    final rawTags = map['tags'];
    if (rawTags is List) {
      for (final item in rawTags) {
        if (item is Map) {
          tags.add(CachedTag.fromMap(Map<String, Object?>.from(item)));
        }
      }
    }
    final updatedAt = map['updatedAt'];
    final at = updatedAt is int
        ? DateTime.fromMillisecondsSinceEpoch(updatedAt)
        : DateTime.fromMillisecondsSinceEpoch(0);
    if (DateTime.now().difference(at) > maxAge) return null;
    return RemoteTagsCache(tags: tags, updatedAt: at);
  }

  /// 清理过期缓存，返回删除条数（启动/设置页可顺手调）。
  Future<int> pruneExpiredRemoteTags({
    Duration maxAge = const Duration(days: 30),
  }) async {
    final db = await _dbFuture;
    final now = DateTime.now().millisecondsSinceEpoch;
    final limit = maxAge.inMilliseconds;
    var removed = 0;
    final all = await _tagsStore.find(db);
    for (final rec in all) {
      final at = rec.value['updatedAt'];
      if (at is int && now - at > limit) {
        await _tagsStore.record(rec.key).delete(db);
        removed++;
      }
    }
    return removed;
  }

  /// 主动失效某仓库缓存（如切换 remote/删仓时调）。
  Future<void> clearRemoteTags(String key) async {
    final db = await _dbFuture;
    await _tagsStore.record(key).delete(db);
  }

  Future<void> close() async {
    final db = await _dbFuture;
    await db.close();
  }
}

Future<Database> _openFileDb() async {
  final file = await _resolveDbFile();
  await file.parent.create(recursive: true);
  return databaseFactoryIo.openDatabase(file.path, version: 1);
}

Future<File> _resolveDbFile() async {
  if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    final base = (appData != null && appData.trim().isNotEmpty)
        ? Directory('${appData.trim()}\\GitGeek')
        : Directory(
            '${Platform.environment['USERPROFILE'] ?? '.'}\\.GitGeek');
    return File(p.join(base.path, 'gitgeek.sembast.db'));
  }
  try {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'GitGeek'));
    return File(p.join(dir.path, 'gitgeek.sembast.db'));
  } catch (_) {
    final home = Platform.environment['HOME'] ?? '.';
    return File(p.join(home, '.GitGeek', 'gitgeek.sembast.db'));
  }
}
