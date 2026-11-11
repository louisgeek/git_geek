import 'package:git_geek/core/error/result.dart';
import 'package:git_geek/features/tags/domain/git_tag.dart';
import 'package:git_geek/core/config/app_lang.dart';

/// Tags 仓储契约（domain 层）。
///
/// presentation 只依赖本抽象，实现（`TagsRepository`）在 data 层，
/// 由组合根 `app/bootstrap.dart` 用 Riverpod overrides 注入。
/// 好处：测试直接 Fake 本接口，不必继承具体类、不受其构造参数变动牵连。
abstract interface class TagsRepositoryContract {
  /// 把 repoPath+scope 解析成实际生效目录（远程 URL 会触发克隆/增量更新）。
  Future<Result<String>> resolveDir(
    String repoPath,
    String scope,
    AppLang lang,
  );

  /// 拉取本地 tag：走 git CLI 直读。
  Future<Result<List<GitTag>>> fetchLocalTags(String dir, AppLang lang);

  /// 拉取远程 tag：成功写透缓存，供离线兜底。
  Future<Result<List<GitTag>>> fetchRemoteTags(
    String dir,
    String remote,
    AppLang lang,
  );

  /// 离线兜底：无网/git 失败时读缓存（过期按未命中处理）。
  /// 实现侧给出 [maxAge] 默认值；接口不写默认值。
  Future<List<GitTag>> cachedRemoteTags(
    String dir,
    String remote, {
    Duration? maxAge,
  });
}
