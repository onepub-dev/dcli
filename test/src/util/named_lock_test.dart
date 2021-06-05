#! /usr/bin/env dcli

@Timeout(Duration(minutes: 10))

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/util/named_lock.dart';
import 'package:test/test.dart';

const port = 63424;

void main() {
  test('lock path', () {
    final lockPath = join(rootPath, Directory.systemTemp.path, 'dcli', 'locks');
    print(lockPath);
  });

  test('timeout catch', () {
    expect(() {
      NamedLock(name: 'timeout').withLock(() {
        throw DCliException('fake exception');
      });
    }, throwsA(isA<DCliException>()));
  }, skip: true);

  test('withLock', () {
    withTempDir((fs) async {
      final logFile = createTempFile();
      print('logfile: $logFile');
      logFile.truncate();

      final portBack = await spawn('background');
      final portMid = await spawn('middle');
      final portFore = await spawn('foreground');

      await portBack.first;
      await portMid.first;
      await portFore.first;

      final actual = read(logFile).toList();

      expect(actual, [
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
      ]);
      delete(logFile);
    });
  }, skip: false);

  test('Thrash test', () async {
    Settings().setVerbose(enabled: false);
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
  }, timeout: const Timeout(Duration(minutes: 3)));
}

void takeHardLock() {
  waitForEx<RawServerSocket>(RawServerSocket.bind(
    '127.0.0.1',
    port,
  ));
}

Future<ReceivePort> spawn(String message) async {
  final back = await Isolate.spawn(takeLock, message, paused: true);
  final port = ReceivePort();
  back
    ..addOnExitListener(port.sendPort)
    ..resume(back.pauseCapability!);
  return port;
}

void takeLock(String message) {
  NamedLock(name: 'test.lock').withLock(() {
    var count = 0;
    for (var i = 0; i < 4; i++) {
      final l = '$message + ${count++}';
      print(l);
      '$HOME/lock.log'.append(l);
      sleep(1);
    }
  });
}

const _lockCheckPath = '/tmp/lockcheck';
final _lockFailedPath = join(_lockCheckPath, 'lock_failed');

/// must be a global function as we us it to spawn an isolate
void worker(int instance) {
  Settings().setVerbose(enabled: false);
  print('starting worker instance $instance');
  NamedLock(name: 'gshared-compile').withLock(() {
    print('acquired lock worker $instance');
    final inLockPath = join(_lockCheckPath, 'inlock');

    /// If the [inLockPath] file exists
    /// then the lock has been breached.
    if (exists(inLockPath)) {
      touch(_lockFailedPath, create: true);
      throw DCliException(
          'NamedLock for $instance failed as another lock is active');
    }

    touch(inLockPath, create: true);

    sleep(5);
    print('finished work $instance');
    delete(inLockPath);
  });
}

class Worker {
  Worker(this.isolate) : exitPort = ReceivePort() {
    isolate
      ..addOnExitListener(exitPort.sendPort)
      ..resume(isolate.pauseCapability!);
  }

  Future<dynamic> waitForExit() async => exitPort.first;
  Isolate isolate;
  ReceivePort exitPort;
}
