@Timeout(Duration(seconds: 600))

import 'dart:io';

import 'package:dcli/src/util/file_sync.dart';
import 'package:dcli/src/util/runnable_process.dart';
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('StringAsProcess', () {
    t.test('Check .run executes', () {
      withTempDir((fs) {
        final testFile = join(fs, 'test.text');

        'touch $testFile'.run;
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Check .start executes - attached, not in shell', () {
      withTempDir((fs) {
        final testFile = join(fs, 'test.text');

        'touch $testFile'.start();
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Check .start executes - attached,  in shell', () {
      withTempDir((fs) {
        final testFile = join(fs, 'test.text');

        'touch $testFile'.start(runInShell: true);

        // Start returns before completion, wait for up to 10 seconds
        // for it to create the file.
        for (var i = 0; i < 10; i++) {
          if (exists(testFile)) {
            break;
          }
          sleep(1);
        }
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Check .start executes - detached, not in shell', () {
      withTempDir((fs) {
        final testFile = join(fs, 'test.text');

        'touch $testFile'.start(detached: true);

        // we have ran a detached process. Wait for up to 10 seconds
        // for it to create the file.
        for (var i = 0; i < 10; i++) {
          if (exists(testFile)) {
            break;
          }
          sleep(1);
        }

        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Check .start executes - detached,  in shell', () {
      withTempDir((fs) {
        final testFile = join(fs, 'test.text');

        'touch $testFile'.start(detached: true, runInShell: true);

        // we have ran a detached process. Wait for up to 10 seconds
        // for it to create the file.
        for (var i = 0; i < 10; i++) {
          if (exists(testFile)) {
            break;
          }
          sleep(1);
        }

        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('forEach', () {
      withTempDir((fs) {
        final lines = <String?>[];

        final linesFile = setup(fs);

        print('pwd: $pwd');

        assert(exists(linesFile), 'The linesfile must exist');

        'tail -n 5 $linesFile'.forEach(lines.add);

        t.expect(lines.length, t.equals(5));
      });
    });

    t.test('toList', () {
      withTempDir((fs) {
        final path = join(fs, 'log/syslog');

        createDir(dirname(path), recursive: true);
        touch(path, create: true);

        path.truncate();

        for (var i = 0; i < 10; i++) {
          path.append('head $i');
        }
        final lines = 'head -n 5 $path'.toList();
        t.expect(lines.length, t.equals(5));
      });
    });

    t.test('toList - nothrow', () {
      final result = 'ls *.fasdafefe'.toList(nothrow: true);
      t.expect(
          result,
          t.equals(
              ["ls: cannot access '*.fasdafefe': No such file or directory"]));
    });

    t.test('toList - exception nothrow=false', () {
      t.expect(() => 'ls *.abcdafe'.toList(), t.throwsA(isA<RunException>()));
    });

    t.test('toList -  exception with nothrow=true', () {
      try {
        'ls *.fasdafefe'.toList(nothrow: true);
      } on RunException catch (e) {
        t.expect(e.exitCode, 2);
        t.expect(e.message,
            "ls: cannot access '*.fasdafefe': No such file or directory");
      }
    });

    t.test('toList - skipLines', () {
      withTempDir((root) {
        final path = join(rootPath, 'tmp', 'log', 'syslog');

        if (exists(path)) {
          deleteDir(dirname(path));
        }
        createDir(dirname(path), recursive: true);
        touch(path, create: true);

        path.truncate();

        for (var i = 0; i < 10; i++) {
          path.append('head $i');
        }
        final expected = ['head 1', 'head 2', 'head 3', 'head 4'];
        final lines = 'head -n 5 $path'.toList(skipLines: 1);
        t.expect(lines, t.equals(expected));

        deleteDir(dirname(path));
      });
    });
  });

  t.test('forEach using runInShell', () {
    var found = false;
    'echo run test'.forEach((line) {
      if (line.contains('run test')) {
        found = true;
      }
    }, runInShell: true);
    t.expect(found, t.equals(true));
  });

  t.test('firstLine', () {
    withTempDir((root) {
      final file = setup(root);
      t.expect('cat $file'.firstLine, 'Line 0');
    });
  });

  t.test('firstLine with stderr', () {
    t.expect('dart --version'.firstLine, t.contains('version'));
  });

  t.test('lastLine', () {
    withTempDir((fs) {
      final file = setup(fs);
      t.expect('cat $file'.lastLine, 'Line 9');
    });
  });
}

String setup(String fsRoot) {
  final linesFile = join(fsRoot, TestFileSystem.testLinesFile);

  withOpenFile(linesFile, (file) {
    for (var i = 0; i < 10; i++) {
      file.append('Line $i');
    }
  });
  return linesFile;
}
