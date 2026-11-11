import 'package:flutter_test/flutter_test.dart';
import 'package:git_geek/core/error/app_error.dart';
import 'package:git_geek/core/error/result.dart';
import 'package:git_geek/shared/l10n/app_error_message.dart';

void main() {
  group('Result 结构化错误', () {
    test('failureOf 让 message 与 AppError.message 保持一致', () {
      final r = Result<int>.failureOf(
        const GitCommandError('git log 失败', command: 'log'),
      );
      expect(r.errorOrNull, 'git log 失败');
      expect(r.appErrorOrNull, isA<GitCommandError>());
      expect((r.appErrorOrNull as GitCommandError).command, 'log');
    });

    test('未提供 error 时 appErrorOrNull 为 null，不破坏旧调用', () {
      const r = Result<int>.failure('原始文案');
      expect(r.errorOrNull, '原始文案');
      expect(r.appErrorOrNull, isNull);
    });

    test('map 透传结构化错误', () {
      final mapped = Result<int>.failureOf(
        const NetworkError('断网'),
      ).map((v) => v * 2);
      expect(mapped.appErrorOrNull, isA<NetworkError>());
    });
  });

  group('AppError 分类语义', () {
    test('网络类可重试，git/平台类不可重试', () {
      expect(const NetworkError('x').isRetryable, isTrue);
      expect(const TimeoutError('x').isRetryable, isTrue);
      expect(const ServerError('x').isRetryable, isTrue);
      expect(const GitCommandError('x').isRetryable, isFalse);
      expect(const PlatformUnsupportedError('x').isRetryable, isFalse);
    });

    test('环境问题与网络问题分开引导', () {
      expect(const GitCommandError('x').isEnvironmentIssue, isTrue);
      expect(const PlatformUnsupportedError('x').isEnvironmentIssue, isTrue);
      expect(const NetworkError('x').isEnvironmentIssue, isFalse);
      expect(const UnauthorizedError('x').isEnvironmentIssue, isFalse);
    });
  });
}
