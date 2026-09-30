import 'package:flutter_test/flutter_test.dart';
import 'package:git_geek/core/result.dart';

void main() {
  group('Result', () {
    test('ok carries value', () {
      const r = Result.ok(42);
      expect(r.isOk, isTrue);
      expect(r.isErr, isFalse);
      expect(r.valueOrNull, 42);
      expect(r.errorOrNull, isNull);
    });

    test('err carries message and cause', () {
      final cause = Exception('boom');
      final r = Result<int>.err('失败', cause: cause);
      expect(r.isErr, isTrue);
      expect(r.isOk, isFalse);
      expect(r.valueOrNull, isNull);
      expect(r.errorOrNull, '失败');
      expect((r as Err<int>).cause, same(cause));
    });

    test('fold dispatches', () {
      expect(
        const Result.ok(1).fold((v) => 'ok:$v', (e) => 'err'),
        'ok:1',
      );
      expect(
        const Result<int>.err('x').fold((v) => 'ok', (e) => 'err:${e.message}'),
        'err:x',
      );
    });

    test('map transforms ok and passes err through', () {
      expect(const Result.ok(2).map((v) => v * 3).valueOrNull, 6);
      final err = const Result<int>.err('x').map((v) => v * 3);
      expect(err.isErr, isTrue);
      expect(err.errorOrNull, 'x');
    });

    test('switch is exhaustive', () {
      String describe(Result<String> r) => switch (r) {
        Ok(:final value) => 'ok:$value',
        Err(:final message) => 'err:$message',
      };
      expect(describe(const Result.ok('a')), 'ok:a');
      expect(describe(const Result.err('b')), 'err:b');
    });
  });
}
