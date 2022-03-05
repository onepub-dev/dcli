import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('non-dcli async exception', () async {
    try {
      waitForEx<void>(doAsyncThrowException());
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      final sti = StackTraceImpl.fromStackTrace(st);

      var index = 0;

      var frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details, equals('_doAsyncThrowException1'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details, equals('doAsyncThrowException'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details, equals('main.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details, equals('main.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('declarer.dart'));
      expect(frame.details,
          equals('Declarer.test.<anonymous closure>.<anonymous closure>'));
    }
  });

  test('non-dcli async error', () async {
    try {
      waitForEx<void>(doAsyncThrowError());
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      final sti = StackTraceImpl.fromStackTrace(st);

      var index = 0;
      var frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details, equals('_doAsyncThrowError1'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details, equals('doAsyncThrowError'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details, equals('main.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details, equals('main.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('declarer.dart'));
      expect(frame.details,
          equals('Declarer.test.<anonymous closure>.<anonymous closure>'));
    }
  });

  test('dcli async exception', () async {
    try {
      waitForEx<void>(doThrowDCliException());
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      final sti = StackTraceImpl.fromStackTrace(st);
      var index = 0;
      var frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details, equals('_doThrowDCliException1'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details, equals('doThrowDCliException'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details, equals('main.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details, equals('main.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('declarer.dart'));
      expect(frame.details,
          equals('Declarer.test.<anonymous closure>.<anonymous closure>'));
    }
  });

  test('dcli with failed moveDir', () async {
    try {
      withTempDir((dir) {
        moveDir(join(dir, 'notadir'), 'dir');
      });
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      final sti = StackTraceImpl.fromStackTrace(st);

      var index = 0;

      var frame = sti.frames[index++];

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('move_dir.dart'));
      expect(frame.details, equals('moveDir'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('move_dir.dart'));
      expect(frame.details, equals('moveDir'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details,
          equals('main.<anonymous closure>.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('create_dir.dart'));
      expect(frame.details, equals('withTempDir'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for.dart'));
      expect(frame.details, equals('waitFor.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex.dart'));
      expect(frame.details, equals('waitForEx'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('move_dir.dart'));
      expect(frame.details, equals('moveDir'));

      frame = sti.frames[index++];
      expect(basename(frame.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame.details,
          equals('main.<anonymous closure>.<anonymous closure>'));
    }
  });
}

Future<void> doAsyncThrowException() async {
  _doAsyncThrowException1();
}

void _doAsyncThrowException1() {
  throw Exception('oh no');
}

Future<void> doAsyncThrowError() async {
  _doAsyncThrowError1();
}

void _doAsyncThrowError1() {
  throw ArgumentError('oh no');
}

Future<void> doThrowDCliException() async {
  _doThrowDCliException1();
}

void _doThrowDCliException1() {
  throw DCliException('oh no');
}
