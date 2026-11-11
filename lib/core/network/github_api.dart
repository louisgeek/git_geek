import 'package:dio/dio.dart';
import 'package:git_geek/core/config/app_config.dart';
import 'package:git_geek/core/error/app_error.dart';
import 'package:git_geek/core/error/result.dart';

/// GitHub REST 最小封装：按需取 remote tags，避免每次都 `git ls-remote`。
/// 约定返回 [Result]，不抛业务异常（取消除外，直接 rethrow 透出）。
class GithubApi {
  final Dio _dio;

  GithubApi(this._dio);

  /// `GET /repos/{owner}/{repo}/tags`，调用方自己解析 owner/repo。
  /// 支持外部传入 [cancelToken] 做取消（取消直接 rethrow，不包成 Failure）；
  /// 其余失败返回 `Result.failure`，信息优先取拦截器已映射的 [AppError.message]。
  Future<Result<List<Map<String, dynamic>>>> listTags({
    required String owner,
    required String repo,
    int perPage = AppConfig.githubTagsPerPage,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        '${AppConfig.githubApiBaseUrl}/repos/$owner/$repo/tags',
        queryParameters: {'per_page': perPage},
        cancelToken: cancelToken,
      );
      final data = res.data ?? const [];
      return Result.success(data.whereType<Map<String, dynamic>>().toList());
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.cancel) rethrow;
      // 优先透出拦截器已映射的 AppError 信息，调用方只读 message 字符串。
      final mapped = e.error;
      if (mapped is AppError) {
        return Result.failure(
          mapped.message,
          error: mapped,
          cause: e,
          stackTrace: st,
        );
      }
      return Result.failure(
        cleanError(e.message ?? e.toString()),
        error: UnknownError(cleanError(e.message ?? e.toString()), cause: e),
        cause: e,
        stackTrace: st,
      );
    }
  }
}
