/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'dart:async';

import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('start with progress', () {
    final result = <String?>[];
    'echo hi'.start(
      runInShell: true,
      progress: Progress(result.add, stderr: result.add),
    );

    expect(result, orderedEquals(<String>['hi']));
  });

  test('stream - using start', () {
    withTempFile((file) {
      file
        ..write('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');

      final progress = Progress.stream();
      'tail $file'.start(progress: progress, runInShell: true);

      final done = Completer<void>();
      progress.stream.listen((event) {
        print('stream: $event');
      }).onDone(done.complete);

      waitForEx<void>(done.future);
      print('done');
    });
  });

  test('stream', () {
    withTempFile((file) {
      file
        ..write('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');

      final stream = 'tail $file'.stream(runInShell: true);

      final done = Completer<void>();
      stream.listen((event) {
        print('stream: $event');
      }).onDone(done.complete);

      waitForEx<void>(done.future);
      print('done');
    });
  });

  test('tail -f', () {
    Settings().setVerbose(enabled: true);

    withTempFile((file) {
      file
        ..write('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');

      final stream = 'tail -f $file'.stream();

      final done = Completer<void>();
      var linesRead = 0;
      print('have stream');
      late final StreamSubscription<String> subscription;
      subscription = stream.listen((event) {
        print('stream: $event');
        linesRead++;

        // ignore: flutter_style_todos
        /// TODO(bsutton): find some way of terminating a streaming process
        /// that doesn't naturally end (e.g. tail -f)
        ///
        if (linesRead == 15) {
          done.complete();
          subscription.cancel();
        }
      });

      for (var i = 0; i < 15; i++) {
        file.append('Line $i');
      }

      waitForEx<void>(done.future);
      print('done');
      expect(linesRead, equals(15));
    });
  });

  test('tail -n 100', () {
    withTempFile((file) {
      file
        ..write('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      Settings().setVerbose(enabled: true);
      final stream = 'tail -n 100 $file'.stream();

      final done = Completer<void>();
      stream.listen((event) {
        print('stream: $event');
      }).onDone(done.complete);

      waitForEx<void>(done.future);
      print('done');
    });
  });

  test('append only', () {
    withTempFile((file) {
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      Settings().setVerbose(enabled: true);
      expect(read(file).toList().length, equals(5));
    });
  });
}
