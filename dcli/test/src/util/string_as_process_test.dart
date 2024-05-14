/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('start with progress', () {
    final result = <String?>[];
    'echo hi'.start(
      runInShell: true,
      extensionSearch: false,
      progress: Progress(result.add, stderr: result.add),
    );

    expect(result, orderedEquals(<String>['hi']));
  });

  test('stream - using start', () async {
    await withTempFile((file) async {
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

      await done.future;
      print('done');
    });
  });

  // test('stream', () async {
  //   await core.withTempFileAsync((file) async {
  //     file
  //       ..write('Line 1/5')
  //       ..append('Line 2/5')
  //       ..append('Line 3/5')
  //       ..append('Line 4/5')
  //       ..append('Line 5/5');

  //     final stream = await 'tail $file'.stream(runInShell: true);

  //     final done = Completer<void>();
  //     stream.listen((event) {
  //       print('stream: $event');
  //     }).onDone(done.complete);

  //     await done.future;
  //     print('done');
  //   });
  // });

  // test('tail -f', () async {
  //   Settings().setVerbose(enabled: false);

  //   await core.withTempFileAsync((file) async {
  //     file
  //       ..write('Line 1/5')
  //       ..append('Line 2/5')
  //       ..append('Line 3/5')
  //       ..append('Line 4/5')
  //       ..append('Line 5/5');

  //     print(file);

  //     /// the stream shouldn't wait for exit as we want to
  //     /// process the data after setting the stream up.
  //     final stream = await 'tail -f $file'.stream();

  //     final done = Completer<void>();
  //     var linesRead = 0;
  //     print('have stream');
  //     late final StreamSubscription<String> subscription;
  //     subscription = stream.listen((event) async {
  //       print('stream: $event');
  //       linesRead++;

  //       // ignore: flutter_style_todos
  //       /// `TODO`(bsutton): find some way of terminating a streaming process
  //       /// that doesn't naturally end (e.g. tail -f)
  //       if (linesRead == 15) {
  //         done.complete();
  //         await subscription.cancel();
  //       }
  //     });

  //     /// `TODO`:
  //     /// Looks like there is a bug in the stream method in that the above
  //     /// listen misses the first 10 or so lines streamed back from the
  //     /// file. The upper limit of 50 is so the test completes
  //     /// until we have a chance of what to do with stream()
  //     for (var i = 0; i < 50; i++) {
  //       file.append('Line $i');
  //     }

  //     await done.future;
  //     print('done');
  //     expect(linesRead, equals(15));
  //   });
  // });

  // test('tail -n 100', () async {
  //   await withTempFile((file) async {
  //     file
  //       ..write('Line 1/5')
  //       ..append('Line 2/5')
  //       ..append('Line 3/5')
  //       ..append('Line 4/5')
  //       ..append('Line 5/5');
  //     final stream = await 'tail -n 100 $file'.stream();

  //     final done = Completer<void>();
  //     stream.listen((event) {
  //       print('stream: $event');
  //     }).onDone(done.complete);

  //     await done.future;
  //     print('done');
  //   });
  // });

  test('append only', () {
    withTempFile((file) {
      file
        ..append('Line 1/5')
        ..append('Line 2/5')
        ..append('Line 3/5')
        ..append('Line 4/5')
        ..append('Line 5/5');
      expect(read(file).toList().length, equals(5));
    });
  });
}
