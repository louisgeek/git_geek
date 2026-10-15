// git 基础设施展示用的文案包：纯 Dart，不依赖 Flutter/shared/features。
//
// 约定：core/git 只收备好的字符串，不直接读 l10n（core 不依赖 shared）；
// 调用方在 features 层按语言填好后传入（见 `AppLang.gitMessages`）。
class GitMessages {
  /// 缓存清理失败：`cacheCleanFail`。
  final String cacheCleanFail;

  /// filter clone 不被托管支持时的回退提示。
  final String filterFallback;

  /// 本地目录不存在。
  final String dirNotExist;

  /// 当前平台不支持本地 git（已按平台名格式化好，如 'Web'）。
  final String platformUnsupported;

  /// 缓存命中后的增量更新提示。
  final String updatingCache;

  /// 增量更新失败、沿用旧缓存的提示（后接异常文本）。
  final String updateStaleCache;

  /// 首次克隆到缓存的提示。
  final String cloningCache;

  /// 克隆后仍不可用的错误（后接仓库地址）。
  final String cloneUnusable;

  const GitMessages({
    required this.cacheCleanFail,
    required this.filterFallback,
    required this.dirNotExist,
    required this.platformUnsupported,
    required this.updatingCache,
    required this.updateStaleCache,
    required this.cloningCache,
    required this.cloneUnusable,
  });
}
