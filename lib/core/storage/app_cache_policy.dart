///标准缓存策略
enum AppCachePolicy {
  cacheFirst,           // 缓存优先：有缓存就直接返回，无缓存则请求网络并写入缓存
  networkFirst,         // 网络优先：优先请求网络并写入缓存，网络失败时读缓存兜底
  cacheOnly,            // 仅读缓存：每次都只读缓存，无缓存就直接报错，不请求网络
  networkOnly,          // 仅请求网络：每次都请求网络，不读不写缓存，失败直接报错
  forceRefresh,         // 强制刷新：每次都请求网络并写入缓存，不读缓存，失败报错
  staleWhileRevalidate, // 先读缓存后更新：立即返回缓存，同时后台请求网络更新缓存
}

extension AppCachePolicyExtension on AppCachePolicy {
  bool get shouldReadCache =>
      this == AppCachePolicy.cacheFirst ||
          this == AppCachePolicy.cacheOnly ||
          this == AppCachePolicy.staleWhileRevalidate;

  bool get shouldWriteCache =>
      this != AppCachePolicy.cacheOnly && this != AppCachePolicy.networkOnly;

  bool get shouldFetchNetwork => this != AppCachePolicy.cacheOnly;

  bool get shouldFallbackToCache => this == AppCachePolicy.networkFirst;
}
