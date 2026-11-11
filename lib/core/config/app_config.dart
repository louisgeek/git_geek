/// 应用级常量与环境配置（core 层）。
///
/// 这里只放「换一个 app 也大概率能复用」的东西：外部服务地址、缓存目录名、
/// 分页/上限等与具体业务无关的数值。GitGeek 专属的业务常量（如偏好 key）
/// 不放这里。
class AppConfig {
  const AppConfig._();

  // ---- 外部服务 ----

  /// GitHub REST API 基址。
  static const String githubApiBaseUrl = 'https://api.github.com';

  // ---- 本地缓存 ----

  /// 远程仓库克隆缓存根目录名（置于平台 AppData/Application Support 下）。
  static const String cacheDirName = 'GitGeek';

  /// 缓存子目录名。
  static const String cacheSubDirName = 'cache';

  /// 远程 tag 离线兜底缓存的有效期。
  static const Duration remoteTagsCacheMaxAge = Duration(days: 7);

  // ---- 查询上限 ----

  /// 提交列表单次拉取上限（防过大拖慢解析）。
  static const int commitFetchLimitMax = 5000;

  /// 子模块参照面板每个子库展示条数。
  static const int submoduleLogLimit = 10;

  /// GitHub tags 单页条数。
  static const int githubTagsPerPage = 100;
}
