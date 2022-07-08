/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';
import 'dart:io';

import 'package:dcli_core/dcli_core.dart';
import 'package:synchronized/synchronized.dart';
import 'package:test/test.dart';

void main() {
  test('limited stream ...', () async {
    final controller = LimitedStreamController<int>(5);
    final done = Completer<bool>();

    Future<void>.delayed(
        const Duration(seconds: 10), () async => controller.close());

    try {
      for (var i = 0; i < 5; i++) {
        await controller.asyncAdd(i);
      }

      Future<void>.delayed(
          const Duration(seconds: 5), () => controller.asyncAdd(6));

      controller.stream.listen(print, onDone: () {
        done.complete(true);
      });
      await done.future;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print(e);
    } finally {
      // await controller.close();
    }
  });

  test('async circular buffer fast add slow get', () async {
    final controller = LimitedStreamController<String>(100);

    final addCompleter = Completer<bool>();
    var addLoop = 20;
    final lock = Lock();
    Timer.periodic(const Duration(milliseconds: 1), (t) async {
      await lock.synchronized(() async {
        if (addLoop > 0) {
          await fill(controller, 100,
              (e) => print('add $addLoop $e Stream Len: ${controller.length}'));
          addLoop--;
          if (addLoop == 0) {
            t.cancel();
            print('cancelled add');
            await controller.close();
            addCompleter.complete(true);
          }
        }
      });
    });

    await withTempFile((pathToLarge) async {
      await _createLargeFile(pathToLarge);
      final getCompleter = Completer<bool>();

      late final StreamSubscription<String> sub;
      sub = controller.stream.listen((event) async {
        sub.pause();
        print(event);

        /// run slow process
        await calculateHash(pathToLarge);
        sub.resume();
      }, onDone: () {
        print('get done');
        getCompleter.complete(true);
      });

      await Future.wait<bool>([addCompleter.future, getCompleter.future]);
      await sub.cancel();
    });
  });
}

Future<void> _createLargeFile(String pathTo) async {
  final file = File(pathTo).openWrite();
  for (var i = 0; i < 1000; i++) {
    file.write('*' * 100);
  }
  await file.close();
}

// Future<void> empty(LimitedStreamController<String> buf, int count,
//     [void Function(String e)? callback]) async {
//   for (var i = 0; i < count; i++) {
//     final val = await buf.get();
//     expect(int.parse(val), equals(i));
//     if (callback != null) {
//       callback(val);
//     }
//   }
// }

Future<void> fill(LimitedStreamController<String> buf, int count,
    [void Function(String e)? callback]) async {
  for (var i = 0; i < count; i++) {
    await buf.asyncAdd('$i');
    buf.toString();
    if (callback != null) {
      callback('$i');
    }
  }
}
