@Timeout(Duration(minutes: 10))
import 'dart:async';

import 'package:test/test.dart';
import 'package:dcli/dcli.dart' hide equals;

void main() {
  test('start with progress', () {
    final result = <String?>[];
    'echo hi'.start(
      runInShell: true,
      progress: Progress((line) => result.add(line),
          stderr: (line) => result.add(line)),
    );

    expect(result, orderedEquals(<String>['hi']));
  });

  test('stream - using start', () {
    '/tmp/access.log'
      ..write('Line 1/5')
      ..append('Line 2/5')
      ..append('Line 3/5')
      ..append('Line 4/5')
      ..append('Line 5/5');

    final progress = Progress.stream();
    'tail /tmp/access.log'.start(
      progress: progress,
      runInShell: true,
    );

    final done = Completer<void>();
    progress.stream.listen((event) {
      print('stream: $event');
    }).onDone(() => done.complete());

    waitForEx<void>(done.future);
    print('done');
  });

  test('stream', () {
    '/tmp/access.log'
      ..write('Line 1/5')
      ..append('Line 2/5')
      ..append('Line 3/5')
      ..append('Line 4/5')
      ..append('Line 5/5');

    final stream = 'tail /tmp/access.log'.stream(
      runInShell: true,
    );

    final done = Completer<void>();
    stream.listen((event) {
      print('stream: $event');
    }).onDone(() => done.complete());

    waitForEx<void>(done.future);
    print('done');
  });

  test('tail -f', () {
    Settings().setVerbose(enabled: true);

    const log = '/tmp/access.log';

    // ignore: cascade_invocations
    log
      ..write('Line 1/5')
      ..append('Line 2/5')
      ..append('Line 3/5')
      ..append('Line 4/5')
      ..append('Line 5/5');

    final stream = 'tail -f $log'.stream(
        // runInShell: true,
        );

    final done = Completer<void>();
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
    const log = '/tmp/access.log';
    // ignore: cascade_invocations
    log..write('Line 1/5')
    ..append('Line 2/5')
    ..append('Line 3/5')
    ..append('Line 4/5')
    ..append('Line 5/5');
    Settings().setVerbose(enabled: true);
    final stream = 'tail -n 100 $log'.stream(
        // runInShell: true,
        );

    final done = Completer<void>();
    stream.listen((event) {
      print('stream: $event');
    }).onDone(() => done.complete());

    waitForEx<void>(done.future);
    print('done');
  });
}
