@Timeout(Duration(minutes: 5))
import 'dart:cli';
import 'dart:convert';
import 'dart:io';

import 'package:dshell/dshell.dart' hide sleep;
import 'package:dshell/src/functions/run.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  test('runnable process Start - forEach', () {
    TestFileSystem().withinZone((fs) async {
      var path = join(fs.root, 'top');
      print('starting ls in $path');

      String command;
      command = 'ls *.txt';
      var found = <String>[];
      start(command, workingDirectory: path).forEach((file) {
        found.add(file);
      });

      expect(found, <String>[
        join(path, 'one.txt'),
        //join(path, '.two.txt'), // we should not be expanding .xx.txt
        join(path, 'two.txt')
      ]);
    });
  });

  test('runnable process Start - forEach', () {
    print('Print to stdout using "print');

    stdout.writeln('Print to stdout using "stsdout.writeln"');

    stderr.writeln('Print to stderr using "stderr.writeln"');

    stderr.write('Print to stderr using "stderr.write"');
    stderr.write('\n');
    printerr('Print to stderr using "printerr"');
  });

  test('Child process shutdown', () {
    var fprocess = Process.start(
      'tail',
      ['-f', '/var/log/syslog'],
      mode: ProcessStartMode.normal,
    );

    fprocess.then((process) {
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

    waitFor<void>(Future.delayed(Duration(seconds: 10)));

    /// test in current form can't actually test for shutdown.
    /// needs to spawn another process then check the outcome.
  }, skip: true);
}
