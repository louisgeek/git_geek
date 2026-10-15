import 'package:flutter_test/flutter_test.dart';
import 'package:git_geek/core/error/result.dart';

void main() {
  group('Result', () {
    test('success carries value', () {
      const r = Result.success(42);
      expect(r.isSuccess, isTrue);
      expect(r.isFailure, isFalse);
      expect(r.valueOrNull, 42);
      expect(r.errorOrNull, isNull);
    });

    test('failure carries message and cause', () {
      final cause = Exception('boom');
      final r = Result<int>.failure('失败', cause: cause);
      expect(r.isFailure, isTrue);
      expect(r.isSuccess, isFalse);
      expect(r.valueOrNull, isNull);
      expect(r.errorOrNull, '失败');
      expect((r as Failure<int>).cause, same(cause));
    });

    test('fold dispatches', () {
      expect(
        const Result.success(1).fold((v) => 'Success:$v', (e) => 'err'),
        'Success:1',
      );
      expect(
        const Result<int>.failure('x').fold((v) => 'success', (e) => 'Failure:${e.message}'),
        'Failure:x',
      );
    });

    test('map transforms success and passes failure through', () {
      expect(const Result.success(2).map((v) => v * 3).valueOrNull, 6);
      final err = const Result<int>.failure('x').map((v) => v * 3);
      expect(err.isFailure, isTrue);
      expect(err.errorOrNull, 'x');
    });

    test('switch is exhaustive', () {
      String describe(Result<String> r) => switch (r) {
        Success(:final value) => 'Success:$value',
        Failure(:final message) => 'Failure:$message',
      };
      expect(describe(const Result.success('a')), 'Success:a');
      expect(describe(const Result.failure('b')), 'Failure:b');
    });
  });
}
