@Timeout(Duration(minutes: 5))
import 'dart:async';

import 'dart:cli';
import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart' hide sleep, equals;
import 'package:dcli/src/functions/run.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  test('runnable process Start - forEach', () {
    TestFileSystem().withinZone((fs) async {
      final path = join(fs.fsRoot, 'top');
      print('starting ls in $path');

      String command;
      command = 'ls *.txt';
      final found = <String?>[];
      start(command, workingDirectory: path).forEach(found.add);

      expect(found, <String>['one.txt', 'two.txt']);
    });
  });

  test('runnable process Start - forEach', () {
    print('Print to stdout using "print');

    stdout.writeln('Print to stdout using "stsdout.writeln"');

    stderr
      ..writeln('Print to stderr using "stderr.writeln"')
      ..write('Print to stderr using "stderr.write"')
      ..write('\n');
    printerr('Print to stderr using "printerr"');
  });

  test('Child process shutdown', () {
    Process.start(
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
  }, skip: true);

  test('Process stderr and stdout', () {
    // final progress =
    //     'test/test_script/general/bin/print_to_both_with_error.dart'
    //         .start(progress: Progress.capture(), nothrow: true);

    final progress = 'pub publish'.start(
        workingDirectory: '/tmp/test/top',
        progress: Progress.print(capture: true),
        nothrow: true);

    // final progress =
    //     'test/test_script/general/bin/print_to_both_with_error.dart'
    //         .start(progress: Progress.print(capture: true), nothrow: true);
    expect(progress.exitCode, equals(65));
    final lines = progress.lines;
    expect(lines.join('\n').contains('Hello World - StdOut'), isTrue);
    expect(lines.join('\n').contains('Hello World - StdErr'), isTrue);
  });
}
