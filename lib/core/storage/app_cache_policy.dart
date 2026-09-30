///标准缓存策略
enum AppCachePolicy {
  cacheFirst,           // 缓存优先：有缓存就直接返回，无缓存则请求网络并写入缓存
  networkFirst,         // 网络优先：优先请求网络并写入缓存，网络失败时读缓存兜底
  cacheOnly,            // 仅读缓存：每次都只读缓存，无缓存就直接报错，不请求网络
  networkOnly,          // 仅请求网络：每次都请求网络，不读不写缓存，失败直接报错
  forceRefresh,         // 强制刷新：每次都请求网络并写入缓存，不读缓存，失败报错
  staleWhileRevalidate, // 先读缓存后更新：立即返回缓存，同时后台请求网络更新缓存
}

/// 缓存策略的读写语义判断。
extension AppCachePolicyExtension on AppCachePolicy {
  /// 是否读缓存。
  /// 是否读缓存。
  bool get shouldReadCache =>
      this == AppCachePolicy.cacheFirst ||
          this == AppCachePolicy.cacheOnly ||
          this == AppCachePolicy.staleWhileRevalidate;

  /// 是否写缓存。
  /// 是否写缓存。
  bool get shouldWriteCache =>
      this != AppCachePolicy.cacheOnly && this != AppCachePolicy.networkOnly;

  /// 是否请求网络。
  bool get shouldFetchNetwork => this != AppCachePolicy.cacheOnly;

  /// 网络失败时是否回退读缓存。
  bool get shouldFallbackToCache => this == AppCachePolicy.networkFirst;
}
