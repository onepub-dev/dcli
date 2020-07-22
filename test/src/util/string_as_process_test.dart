import 'dart:async';

import 'package:test/test.dart';
import 'package:dshell/dshell.dart';

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
}
