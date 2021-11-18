import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('non-dcli async exception', () async {
    try {
      waitForEx<void>(doAsyncThrowException());
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      final sti = StackTraceImpl.fromStackTrace(st);
      final frame0 = sti.frames[0];
      expect(basename(frame0.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame0.details, equals('_doAsyncThrowException1'));

      final frame1 = sti.frames[1];
      expect(basename(frame1.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame1.details, equals('doAsyncThrowException'));

      final frame2 = sti.frames[2];
      expect(basename(frame2.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame2.details, equals('main.<anonymous closure>'));
    }
  });

  test('non-dcli async error', () async {
    try {
      waitForEx<void>(doAsyncThrowError());
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      final sti = StackTraceImpl.fromStackTrace(st);
      final frame0 = sti.frames[0];
      expect(basename(frame0.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame0.details, equals('_doAsyncThrowError1'));

      final frame1 = sti.frames[1];
      expect(basename(frame1.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame1.details, equals('doAsyncThrowError'));

      final frame2 = sti.frames[2];
      expect(basename(frame2.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame2.details, equals('main.<anonymous closure>'));
    }
  });

  test('dcli async exception', () async {
    try {
      waitForEx<void>(doThrowDCliException());
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      final sti = StackTraceImpl.fromStackTrace(st);
      final frame0 = sti.frames[0];
      expect(basename(frame0.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame0.details, equals('_doThrowDCliException1'));

      final frame1 = sti.frames[1];
      expect(basename(frame1.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame1.details, equals('doThrowDCliException'));

      final frame2 = sti.frames[2];
      expect(basename(frame2.sourceFile.path), equals('wait_for_ex_test.dart'));
      expect(frame2.details, equals('main.<anonymous closure>'));
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
      expect(basename(frame.sourceFile.path), equals('move_dir.dart'));
      expect(frame.details, equals('_MoveDir.moveDir'));

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
