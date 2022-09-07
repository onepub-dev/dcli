/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';

import 'package:dcli_core/src/util/async_circular_buffer.dart';
import 'package:synchronized/synchronized.dart';
import 'package:test/test.dart';

void main() {
  test('async circular buffer fill and empty', () async {
    final buf = AsyncCircularBuffer<String>(5);

    await fill(buf, 5);

    await empty(buf, 5);
  });

  test('async circular buffer fill and empty x 2', () async {
    final buf = AsyncCircularBuffer<String>(5);

    await fill(buf, 5);
    await empty(buf, 5);
    await fill(buf, 5);
    await empty(buf, 5);
    expect(buf.length, equals(0));
  });

  test('async circular buffer overflow small theshold', () async {
    final buf = AsyncCircularBuffer<String>(4);

    Future<void>.delayed(const Duration(seconds: 2), buf.drain);

    /// try to over-fill
    await fill(buf, 5);

    /// should be 1 element as the drain will have run.
    expect(buf.length, equals(1));
  });

  test('async circular buffer underflow small threshold', () async {
    final buf = AsyncCircularBuffer<String>(4);

    Future<void>.delayed(const Duration(seconds: 2), () async {
      await fill(buf, 4);
    });

    /// try to read too many.
    await empty(buf, 4);

    /// Do it again to ensure state has been reset correctly
    /// after we drained the queue
    Future<void>.delayed(const Duration(seconds: 2), () async {
      await fill(buf, 4);
    });

    /// try to read too many.
    await empty(buf, 4);

    /// should be zero element as the delayed add will have run.
    expect(buf.length, equals(0));
  });

  test('async circular buffer thrash', () async {
    final buf = AsyncCircularBuffer<String>(4);

    final addCompleter = Completer<bool>();
    var addLoop = 20;
    Timer.periodic(const Duration(seconds: 1), (t) async {
      await fill(buf, 5);
      addLoop--;
      if (addLoop == 0) {
        t.cancel();
        addCompleter.complete(true);
      }
    });

    final getCompleter = Completer<bool>();
    var getLoop = 20;
    Timer.periodic(const Duration(seconds: 1), (t) async {
      /// try to read too many.
      await empty(buf, 5);
      getLoop--;
      if (getLoop == 0) {
        t.cancel();
        getCompleter.complete(true);
      }
    });

    await Future.wait<bool>([addCompleter.future, getCompleter.future]);

    /// should be zero element as the delayed add will have run.
    expect(buf.length, equals(0));
  });

  test('async circular buffer fast add slow get', () async {
    final buf = AsyncCircularBuffer<String>(100);

    final addCompleter = Completer<bool>();
    var addLoop = 20;
    final lock = Lock();
    Timer.periodic(const Duration(milliseconds: 1), (t) async {
      await lock.synchronized(() async {
        if (addLoop > 0) {
          await fill(buf, 100, (e) => print('add $addLoop $e'));
          addLoop--;
          if (addLoop == 0) {
            t.cancel();
            print('cancelled add');
            addCompleter.complete(true);
          }
        }
      });
    });

    final getCompleter = Completer<bool>();
    var getLoop = 20;
    Timer.periodic(const Duration(seconds: 1), (t) async {
      /// try to read too many.
      await empty(buf, 100, (e) => print('get $getLoop $e'));
      getLoop--;
      if (getLoop == 0) {
        t.cancel();
        getCompleter.complete(true);
      }
    });

    await Future.wait<bool>([addCompleter.future, getCompleter.future]);

    /// should be zero element as the delayed add will have run.
    expect(buf.length, equals(0));
  });

  test('close when adding', () async {
    final buf = AsyncCircularBuffer<String>(5);
    await buf.add('1');
    buf.close();
    expect(() => buf.add('2'), throwsA(isA<BadStateException>()));
  });

  test('close when getting', () async {
    final buf = AsyncCircularBuffer<String>(5);
    await buf.add('1');
    buf.close();
    await buf.get();
    expect(buf.get, throwsA(isA<UnderflowException>()));
  });
}

Future<void> empty(AsyncCircularBuffer<String> buf, int count,
    [void Function(String e)? callback]) async {
  for (var i = 0; i < count; i++) {
    final val = await buf.get();
    expect(int.parse(val), equals(i));
    if (callback != null) {
      callback(val);
    }
  }
}

Future<void> fill(AsyncCircularBuffer<String> buf, int count,
    [void Function(String e)? callback]) async {
  for (var i = 0; i < count; i++) {
    await buf.add('$i');
    buf.toString();
    if (callback != null) {
      callback('$i');
    }
  }
}
