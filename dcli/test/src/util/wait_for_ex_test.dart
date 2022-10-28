/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' hide equals;
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  test('non-dcli async exception', () async {
    try {
      waitForEx<void>(doAsyncThrowException());
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      final sti = Trace.from(st);

      var index = 0;

      var frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for_ex_test.dart'));
      expect(frame.location, equals('_doAsyncThrowException1'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for_ex_test.dart'));
      expect(frame.location, equals('doAsyncThrowException'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for_ex_test.dart'));
      expect(frame.location, equals('main.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('declarer.dart'));
      expect(frame.location,
          equals('Declarer.test.<anonymous closure>.<anonymous closure>'));
    }
  });

  test('non-dcli async error', () async {
    try {
      waitForEx<void>(doAsyncThrowError());
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      final sti = Trace.from(st);

      var index = 0;
      var frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for_ex_test.dart'));
      expect(frame.location, equals('_doAsyncThrowError1'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for_ex_test.dart'));
      expect(frame.location, equals('doAsyncThrowError'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for_ex_test.dart'));
      expect(frame.location, equals('main.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('declarer.dart'));
      expect(frame.location,
          equals('Declarer.test.<anonymous closure>.<anonymous closure>'));
    }
  });

  test('dcli async exception', () async {
    try {
      waitForEx<void>(doThrowDCliException());
      // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      final sti = Trace.from(st);
      var index = 0;
      var frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for_ex_test.dart'));
      expect(frame.location, equals('_doThrowDCliException1'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for_ex_test.dart'));
      expect(frame.location, equals('doThrowDCliException'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for_ex_test.dart'));
      expect(frame.location, equals('main.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('declarer.dart'));
      expect(frame.location,
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
      final sti = Trace.from(st);

      var index = 0;

      var frame = sti.frames[index++];

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('move_dir.dart'));
      expect(frame.location, equals('moveDir'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('move_dir.dart'));
      expect(frame.location, equals('moveDir'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for_ex_test.dart'));
      expect(frame.location,
          equals('main.<anonymous closure>.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('create_dir.dart'));
      expect(frame.location, equals('withTempDir'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for.dart'));
      expect(frame.location, equals('waitFor.<anonymous closure>'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for_ex.dart'));
      expect(frame.location, equals('waitForEx'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('move_dir.dart'));
      expect(frame.location, equals('moveDir'));

      frame = sti.frames[index++];
      expect(basename(frame.library), equals('wait_for_ex_test.dart'));
      expect(frame.location,
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
