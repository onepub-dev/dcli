@Timeout(Duration(minutes: 10))
import 'dart:async';

import 'package:test/test.dart';
import 'package:dshell/dshell.dart' hide equals;

void main() {
  test('start with progress', () {
    var result = <String>[];
    'echo hi'.start(
      runInShell: true,
      progress: Progress((line) => result.add(line),
          stderr: (line) => result.add(line)),
    );

    expect(result, orderedEquals(<String>['hi']));
  });

  test('stream - using start', () {
    var progress = Progress.stream();
    'tail /var/log/syslog'.start(
      progress: progress,
      runInShell: true,
    );

    var done = Completer<void>();
    progress.stream.listen((event) {
      print('stream: $event');
    }).onDone(() => done.complete());

    waitForEx<void>(done.future);
    print('done');
  });

  test('stream', () {
    var stream = 'tail /var/log/syslog'.stream(
      runInShell: true,
    );

    var done = Completer<void>();
    stream.listen((event) {
      print('stream: $event');
    }).onDone(() => done.complete());

    waitForEx<void>(done.future);
    print('done');
  });

  test('tail -f', () {
    Settings().setVerbose(enabled: true);

    var log = '/tmp/access.log';
    log.write('Line 1/5');
    log.append('Line 2/5');
    log.append('Line 3/5');
    log.append('Line 4/5');
    log.append('Line 5/5');

    var stream = 'tail -f $log'.stream(
        // runInShell: true,
        );

    var done = Completer<void>();
    var linesRead = 0;
    print('have stream');
    stream.listen((event) {
      print('stream: $event');
      linesRead++;

      /// TODO: find some way of terminating a streaming process
      /// that doesn't naturally end (e.g. tail -f)
      ///
      if (linesRead == 15) {
        done.complete();
      }
    });

    for (var i = 0; i < 10; i++) {
      log.append('Line $i');
    }

    waitForEx<void>(done.future);
    print('done');
    expect(linesRead, equals(15));
  });

  test('tail -n 100', () {
    var log = '/tmp/access.log';
    log.write('Line 1/5');
    log.append('Line 2/5');
    log.append('Line 3/5');
    log.append('Line 4/5');
    log.append('Line 5/5');
    Settings().setVerbose(enabled: true);
    var stream = 'tail -n 100 $log'.stream(
        // runInShell: true,
        );

    var done = Completer<void>();
    stream.listen((event) {
      print('stream: $event');
    }).onDone(() => done.complete());

    waitForEx<void>(done.future);
    print('done');
  });
}
