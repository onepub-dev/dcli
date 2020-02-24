@Timeout(Duration(seconds: 600))

import 'dart:io';

import 'package:dshell/src/util/file_sync.dart';
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  Settings().debug_on = true;

  t.group('StringAsProcess', () {
    t.test('Check .run executes', () {
      TestFileSystem().withinZone((fs) {
        var testFile = join(fs.root, 'test.text');

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch $testFile'.run;
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Check .start executes - attached, not in shell', () {
      TestFileSystem().withinZone((fs) {
        var testFile = join(fs.root, 'test.text');

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch $testFile'.start();
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Check .start executes - attached,  in shell', () {
      TestFileSystem().withinZone((fs) {
        var testFile = join(fs.root, 'test.text');

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
        var testFile = join(fs.root, 'test.text');

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
        var testFile = join(fs.root, 'test.text');

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
        var lines = <String>[];

        var linesFile = setup(fs);

        print('pwd: ' + pwd);

        assert(exists(linesFile));

        'tail -n 5 $linesFile'.forEach((line) => lines.add(line));

        t.expect(lines.length, t.equals(5));
      });
    });

    t.test('toList', () {
      TestFileSystem().withinZone((fs) {
        var path = join(Directory.systemTemp.path, 'log/syslog');

        if (exists(path)) {
          deleteDir(dirname(path), recursive: true);
        }
        createDir(dirname(path), recursive: true);
        touch(path, create: true);

        path.truncate();

        for (var i = 0; i < 10; i++) {
          path.append('head $i');
        }
        var lines = 'head -n 5 $path'.toList();
        t.expect(lines.length, t.equals(5));
        deleteDir(dirname(path), recursive: true);
      });
    });

    t.test('toList - skipLines', () {
      TestFileSystem().withinZone((fs) {
        var path = '/tmp/log/syslog';

        if (exists(path)) {
          deleteDir(dirname(path), recursive: true);
        }
        createDir(dirname(path), recursive: true);
        touch(path, create: true);

        path.truncate();

        for (var i = 0; i < 10; i++) {
          path.append('head $i');
        }
        var expected = ['head 1', 'head 2', 'head 3', 'head 4'];
        var lines = 'head -n 5 $path'.toList(skipLines: 1);
        t.expect(lines, t.equals(expected));

        deleteDir(dirname(path), recursive: true);
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
      var file = setup(fs);
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
      var file = setup(fs);
      t.expect('cat $file'.lastLine, 'Line 9');
    });
  });
}

String setup(TestFileSystem fs) {
  var linesFile = join(fs.root, TestFileSystem.TEST_LINES_FILE);

  var file = FileSync(linesFile);
  for (var i = 0; i < 10; i++) {
    file.append('Line $i');
  }
  return linesFile;
}
