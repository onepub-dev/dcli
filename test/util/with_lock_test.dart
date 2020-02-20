#! /usr/bin/env dshell
import 'dart:async';
import 'dart:isolate';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/with_lock.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  TestFileSystem();

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

Future<ReceivePort> spawn(String message) async {
  var back = await Isolate.spawn(takeLock, message, paused: true);
  var port = ReceivePort();
  back.addOnExitListener(port.sendPort);
  back.resume(back.pauseCapability);
  return port;
}

void takeLock(String message) {
  Lock(lockSuffix: 'test.lock').withLock(() {
    var count = 0;
    for (var i = 0; i < 4; i++) {
      var l = '$message + ${count++}';
      print(l);
      '$HOME/lock.log'.append(l);
      sleep(1);
    }
  });
}
