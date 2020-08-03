#! /usr/bin/env dshell
@Timeout(Duration(minutes: 10))

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/named_lock.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

final port = 63424;

void main() {
  test('lock path', () {
    var lockPath = join(rootPath, Directory.systemTemp.path, 'dshell', 'locks');
    print(lockPath);
  });

  // test('Thrash test', () {
  //   for (var i = 0; i < 20; i++) {
  //     print('spawning worker $i');
  //     Isolate.spawn(worker, i);
  //   }
  //   sleep(59);
  // }, timeout: Timeout(Duration(minutes: 2)));

  test('timeout catch', () {
    expect(() {
      TestFileSystem().withinZone((fs) async {
        NamedLock(name: 'timeout').withLock(() {
          throw DShellException('fake exception');
        });
      });
    }, throwsA(TypeMatcher<DShellException>()));
  }, skip: true);

  test('withLock', () {
    TestFileSystem().withinZone((fs) async {
      var logFile = fs.tempFile(suffix: 'log');
      print('logfile: $logFile');
      logFile.truncate();

      var portBack = await spawn('background');
      var portMid = await spawn('middle');
      var portFore = await spawn('foreground');

      await portBack.first;
      await portMid.first;
      await portFore.first;

      var actual = read(logFile).toList();

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
}

void takeHardLock() {
  waitForEx<RawServerSocket>(RawServerSocket.bind(
    '127.0.0.1',
    port,
  ));
}

Future<ReceivePort> spawn(String message) async {
  var back = await Isolate.spawn(takeLock, message, paused: true);
  var port = ReceivePort();
  back.addOnExitListener(port.sendPort);
  back.resume(back.pauseCapability);
  return port;
}

void takeLock(String message) {
  NamedLock(name: 'test.lock').withLock(() {
    var count = 0;
    for (var i = 0; i < 4; i++) {
      var l = '$message + ${count++}';
      print(l);
      '$HOME/lock.log'.append(l);
      sleep(1);
    }
  });
}

void worker(int instance) {
  // Settings().setVerbose(enabled: true);
  print('starting worker instance $instance');
  NamedLock(name: 'gshared-compile').withLock(() {
    print('acquired lock worker $instance');
    sleep(5);
    print('finished work $instance');
  });
}
