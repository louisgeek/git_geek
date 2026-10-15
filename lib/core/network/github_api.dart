import 'package:dio/dio.dart';
import 'package:git_geek/core/error/app_error.dart';

/// 领域异常：调用方只依赖它，不依赖 Dio 类型。
/// 新代码优先用 [AppError] 子类，老 [GithubApiException] 保留做兼容过渡。
class GithubApiException implements Exception {
  final int? statusCode;
  final String message;

  const GithubApiException(this.message, {this.statusCode});

  @override
  String toString() => 'GithubApiException($statusCode): $message';
}

/// GitHub REST 最小封装：按需取 remote tags，避免每次都 `git ls-remote`。
class GithubApi {
  final Dio _dio;

  GithubApi(this._dio);

  /// `GET /repos/{owner}/{repo}/tags`，调用方自己解析 owner/repo。
  /// 支持外部传入 [cancelToken] 做取消；失败抛 [GithubApiException]。
  Future<List<Map<String, dynamic>>> listTags({
    required String owner,
    required String repo,
    int perPage = 100,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        'https://api.github.com/repos/$owner/$repo/tags',
        queryParameters: {'per_page': perPage},
        cancelToken: cancelToken,
      );
      final data = res.data ?? const [];
      return data.whereType<Map<String, dynamic>>().toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      // 优先透出拦截器已映射的 AppError 信息。
      final mapped = e.error;
      if (mapped is AppError) {
        throw GithubApiException(
          mapped.message,
          statusCode: mapped.statusCode,
        );
      }
      throw GithubApiException(
        e.message ?? e.toString(),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
