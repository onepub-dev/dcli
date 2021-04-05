#! /usr/bin/env dcli

@Timeout(Duration(minutes: 10))

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/util/named_lock.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

const port = 63424;

void main() {
  test('lock path', () {
    final lockPath = join(rootPath, Directory.systemTemp.path, 'dcli', 'locks');
    print(lockPath);
  });

  test('timeout catch', () {
    expect(() {
      TestFileSystem().withinZone((fs) async {
        NamedLock(name: 'timeout').withLock(() {
          throw DCliException('fake exception');
        });
      });
    }, throwsA(const TypeMatcher<DCliException>()));
  }, skip: true);

  test('withLock', () {
    TestFileSystem().withinZone((fs) async {
      final logFile = fs.tempFile(suffix: 'log');
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

  test('Thrash test', () {
    Settings().setVerbose(enabled: false);
    if (exists(_lockCheckPath)) {
      deleteDir(_lockCheckPath);
    }

    createDir(_lockCheckPath, recursive: true);

    for (var i = 0; i < 20; i++) {
      print('spawning worker $i');
      Isolate.spawn(worker, i);
    }
    sleep(59);

    expect(exists(_lockFailedPath), equals(false));
  }, timeout: const Timeout(Duration(minutes: 2)));
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
