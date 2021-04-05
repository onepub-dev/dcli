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
      TestFileSystem().withinZone((fs) {
        final testFile = join(fs.fsRoot, 'test.text');

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch $testFile'.run;
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Check .start executes - attached, not in shell', () {
      TestFileSystem().withinZone((fs) {
        final testFile = join(fs.fsRoot, 'test.text');

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch $testFile'.start();
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Check .start executes - attached,  in shell', () {
      TestFileSystem().withinZone((fs) {
        final testFile = join(fs.fsRoot, 'test.text');

        if (exists(testFile)) {
          delete(testFile);
        }

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
      TestFileSystem().withinZone((fs) {
        final testFile = join(fs.fsRoot, 'test.text');

        if (exists(testFile)) {
          delete(testFile);
        }

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
      TestFileSystem().withinZone((fs) {
        final testFile = join(fs.fsRoot, 'test.text');

        if (exists(testFile)) {
          delete(testFile);
        }

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
      TestFileSystem().withinZone((fs) {
        final lines = <String?>[];

        final linesFile = setup(fs);

        print('pwd: $pwd');

        assert(exists(linesFile), 'The linesfile must exist');

        'tail -n 5 $linesFile'.forEach(lines.add);

        t.expect(lines.length, t.equals(5));
      });
    });

    t.test('toList', () {
      TestFileSystem().withinZone((fs) {
        final path = join(Directory.systemTemp.path, 'log/syslog');

        if (exists(path)) {
          deleteDir(dirname(path));
        }
        createDir(dirname(path), recursive: true);
        touch(path, create: true);

        path.truncate();

        for (var i = 0; i < 10; i++) {
          path.append('head $i');
        }
        final lines = 'head -n 5 $path'.toList();
        t.expect(lines.length, t.equals(5));
        deleteDir(dirname(path));
      });
    });

    t.test('toList - nothrow', () {
      TestFileSystem().withinZone((fs) {
        final result = 'ls *.fasdafefe'.toList(nothrow: true);
        t.expect(
            result,
            t.equals([
              "ls: cannot access '*.fasdafefe': No such file or directory"
            ]));
      });
    });

    t.test('toList - exception nothrow=false', () {
      TestFileSystem().withinZone((fs) {
        t.expect(() => 'ls *.abcdafe'.toList(),
            t.throwsA(const t.TypeMatcher<RunException>()));
      });
    });

    t.test('toList -  exception with nothrow=true', () {
      TestFileSystem().withinZone((fs) {
        try {
          'ls *.fasdafefe'.toList(nothrow: true);
        } on RunException catch (e) {
          t.expect(e.exitCode, 2);
          t.expect(e.message,
              "ls: cannot access '*.fasdafefe': No such file or directory");
        }
      });
    });

    t.test('toList - skipLines', () {
      TestFileSystem().withinZone((fs) {
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
    TestFileSystem().withinZone((fs) {
      var found = false;
      'echo run test'.forEach((line) {
        if (line.contains('run test')) {
          found = true;
        }
      }, runInShell: true);
      t.expect(found, t.equals(true));
    });
  });

  t.test('firstLine', () {
    TestFileSystem().withinZone((fs) {
      final file = setup(fs);
      t.expect('cat $file'.firstLine, 'Line 0');
    });
  });

  t.test('firstLine with stderr', () {
    TestFileSystem().withinZone((fs) {
      t.expect('dart --version'.firstLine, t.contains('version'));
    });
  });

  t.test('lastLine', () {
    TestFileSystem().withinZone((fs) {
      final file = setup(fs);
      t.expect('cat $file'.lastLine, 'Line 9');
    });
  });
}

String setup(TestFileSystem fs) {
  final linesFile = join(fs.fsRoot, TestFileSystem.testLinesFile);

  final file = FileSync(linesFile);
  for (var i = 0; i < 10; i++) {
    file.append('Line $i');
  }
  return linesFile;
}
