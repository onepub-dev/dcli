#! /usr/bin/env dcli

@Timeout(Duration(minutes: 10))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

/// Throws [DCliException].
/// @Throwing(ArgumentError)
/// @Throwing(CreateDirException)
/// @Throwing(core.DCliException)
/// @Throwing(DeleteDirException)
/// @Throwing(DeleteException)
/// @Throwing(core.TouchException)
void main() {
  group('NamedLock', () {
    test('callback', () async {
      var called = false;
      await NamedLock(name: 'exception')
          .withLockAsync(() async => called = true);
      expect(called, isTrue);
    });

    test('run process', () async {
      String? line;
      await NamedLock(name: 'exception').withLockAsync(() async {
        line = 'ps -q 1 -o comm='.firstLine;
      });
      expect(line, isNotNull);
    });

    test('exception catch', () {
      expect(
        NamedLock(name: 'exception')
            .withLockAsync(() async => throw DCliException('fake exception')),
        throwsA(isA<DCliException>()),
      );
    });

    test(
      'withLock',
      () async {
        await core.withTempDirAsync(
          (fs) async {
            await core.withTempFileAsync((logFile) async {
              print('logfile: $logFile');
              logFile.truncate();

              final portBack = await spawn('background', logFile);
              final portMid = await spawn('middle', logFile);
              final portFore = await spawn('foreground', logFile);

              await portBack.first;
              await portMid.first;
              await portFore.first;

              print('readling logfile');

              final actual = read(logFile).toList();

              expect(
                actual,
                unorderedEquals(<String>[
                  'background + 0',
                  'background + 1',
                  'background + 2',
                  'background + 3',
                  'middle + 0',
                  'middle + 1',
                  'middle + 2',
                  'middle + 3',
                  'foreground + 0',
                  'foreground + 1',
                  'foreground + 2',
                  'foreground + 3',
                ]),
              );
            });
          },
          keep: true,
        );
      },
      skip: false,
    );

    test('Thrash test', () async {
      if (exists(_lockCheckPath)) {
        deleteDir(_lockCheckPath);
      }

      createDir(_lockCheckPath, recursive: true);

      final group = FutureGroup<dynamic>();

      final workers = <Worker>[];
      for (var i = 0; i < 10; i++) {
        print('spawning worker $i');
        final workerIsolate = Isolate.spawn(worker, i, paused: true);
        final iWorker = Worker(await workerIsolate);
        workers.add(iWorker);
        group.add(iWorker.waitForExit());
      }
      group.close();

      await group.future;

      expect(exists(_lockFailedPath), equals(false));
    }, timeout: const Timeout(Duration(minutes: 30)), skip: true);
  });
}

Future<ReceivePort> spawn(String message, String logFile) async {
  final back =
      await Isolate.spawn(writeToLog, '$message;$logFile', paused: true);
  final port = ReceivePort();
  back
    ..addOnExitListener(port.sendPort)
    ..resume(back.pauseCapability!);
  return port;
}

Future<void> writeToLog(String data) async {
  final parts = data.split(';');
  final message = parts[0];
  final log = parts[1];
  await NamedLock(name: 'test').withLockAsync(() async {
    var count = 0;
    for (var i = 0; i < 4; i++) {
      final l = '$message + ${count++}';
      print('isolate: $l');
      log.append(l);
      sleep(1);
    }
  });

  print('Finished Write to Log for $message');
}

const _lockCheckPath = '/tmp/lockcheck';
final String _lockFailedPath = join(_lockCheckPath, 'lock_failed');

/// must be a global function as we us it to spawn an isolate
/// Throws [DCliException].
/// @Throwing(ArgumentError)
/// @Throwing(core.DCliException)
/// @Throwing(core.TouchException)
Future<void> worker(int instance) async {
  print('starting worker instance $instance ${DateTime.now()}');
  await NamedLock(name: 'gshared-compile').withLockAsync(() async {
    print('acquired lock worker $instance  ${DateTime.now()}');
    final inLockPath = join(_lockCheckPath, 'inlock');

    /// If the [inLockPath] file exists
    /// then the lock has been breached.
    if (exists(inLockPath)) {
      touch(_lockFailedPath, create: true);
      throw DCliException(
        'NamedLock for $instance failed as another lock is active',
      );
    }

    touch(inLockPath, create: true);

    sleep(2);
    print('finished work $instance  ${DateTime.now()}');
    delete(inLockPath);
  });
  print('released lock $instance  ${DateTime.now()}');
}

class Worker {
  Isolate isolate;

  ReceivePort exitPort;

  Worker(this.isolate) : exitPort = ReceivePort() {
    isolate
      ..addOnExitListener(exitPort.sendPort)
      ..resume(isolate.pauseCapability!);
  }

  Future<dynamic> waitForExit() => exitPort.first;
}
