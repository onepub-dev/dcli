@Timeout(Duration(minutes: 5))
import 'dart:cli';
import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart' hide sleep;
import 'package:dcli/src/functions/run.dart';
import 'package:path/path.dart';
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
}
