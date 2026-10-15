import 'package:dio/dio.dart';

/// 构建 Dio：baseUrl 由调用方按需填完整 url，默认头只放通用 Accept。
/// 超时按 GitHub REST 经验值：连接 15s、接收 30s、发送 15s。
/// 拦截器挂载顺序由调用方决定：logging → auth → error。
Dio buildDio() {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/vnd.github+json'},
    ),
  );
}
