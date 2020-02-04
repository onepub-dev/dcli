import 'package:dshell/src/util/file_sync.dart';
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_fs_zone.dart';
import '../util/test_paths.dart';

void main() {
  TestPaths();

  Settings().debug_on = true;

  t.group('StringAsProcess', () {
    t.test('Check .run executes', () {
      TestZone().run(() {
        var testFile = 'test.text';

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch test.text'.run;
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Check .start executes - attached, not in shell', () {
      TestZone().run(() {
        var testFile = 'test.text';

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch test.text'.start();
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Check .start executes - attached,  in shell', () {
      TestZone().run(() {
        var testFile = 'test.text';

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch test.text'.start(runInShell: true);

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
      TestZone().run(() {
        var testFile = 'test.text';

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch test.text'.start(detached: true);

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
      TestZone().run(() {
        var testFile = 'test.text';

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch test.text'.start(detached: true, runInShell: true);

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
      TestZone().run(() {
        var lines = <String>[];

        var linesFile = setup();

        print('pwd: ' + pwd);

        assert(exists(linesFile));

        'tail -n 5 $linesFile'.forEach((line) => lines.add(line));

        t.expect(lines.length, t.equals(5));
      });
    });

    t.test('toList', () {
      TestZone().run(() {
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
        var lines = 'head -n 5 $path'.toList();
        t.expect(lines.length, t.equals(5));
      });
    });

    t.test('toList - skipLines', () {
      TestZone().run(() {
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
      var file = setup();
      t.expect('cat $file'.firstLine, 'Line 0');
    });

    t.test('firstLine with stderr', () {
      t.expect('dart --version'.firstLine, t.contains('version'));
    });

    t.test('lastLine', () {
      var file = setup();
      t.expect('cat $file'.lastLine, 'Line 9');
    });
  });
}

String setup() {
  var linesFile = join(TestPaths.TEST_ROOT, TestPaths.TEST_LINES_FILE);

  if (exists(TestPaths.TEST_ROOT)) {
    deleteDir(TestPaths.TEST_ROOT, recursive: true);
  }

  createDir(TestPaths.TEST_ROOT);

  var file = FileSync(linesFile);
  for (var i = 0; i < 10; i++) {
    file.append('Line $i');
  }
  return linesFile;
}
