// ignore_for_file: deprecated_member_use

@Timeout(Duration(minutes: 5))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';
import 'dart:cli';
import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart' hide sleep;
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test(
    'runnable process Start - forEach',
    () async {
      await TestFileSystem().withinZone((fs) async {
        final path = join(fs.fsRoot, 'top');
        print('starting ls in $path');

        String command;
        command = 'ls *.txt';
        final found = <String?>[];

        // TODO(bsutton): the progress is a hack to get around the fact that
        //for each is currently broken. https://github.com/onepub.dev/dcli/issues/144
        start(
          command,
          workingDirectory: path,
          progress: Progress.capture(),
        ).forEach(found.add);

        expect(found, <String>['one.txt', 'two.txt']);
      });
    },
    skip: true,
  );

  test('runnable process Start - forEach', () {
    print('Print to stdout using "print');

    stdout.writeln('Print to stdout using "stsdout.writeln"');

    stderr
      ..writeln('Print to stderr using "stderr.writeln"')
      ..write('Print to stderr using "stderr.write"')
      ..write('\n');
    printerr('Print to stderr using "printerr"');
  });

  test(
    'Child process shutdown',
    () async {
      await Process.start(
        'tail',
        ['-f', '/var/log/syslog'],
      ).then((process) {
        process.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((line) {
          print('stdout: $line');
        });

        process.exitCode.then((exitCode) {
          print('tail exited with $exitCode');
        });
      });

      waitFor<void>(Future.delayed(const Duration(seconds: 10)));

      /// test in current form can't actually test for shutdown.
      /// needs to spawn another process then check the outcome.
    },
    skip: true,
  );

  test('Process stderr and stdout', () {
    final progress = DartSdk().run(
      args: [
        join(
          '..',
          'dcli_unit_tester',
          'test',
          'test_script',
          'general',
          'bin',
          'print_to_both_with_error.dart',
        )
      ],
      progress: Progress.print(capture: true),
      nothrow: true,
    );
    expect(progress.exitCode, equals(25));
    final paragraph = progress.toParagraph();
    expect(paragraph.contains('Hello World - StdOut'), isTrue);
    expect(paragraph.contains('Hello World - StdErr'), isTrue);
  });
}
