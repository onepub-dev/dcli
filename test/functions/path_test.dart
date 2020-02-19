import 'dart:io';

import 'package:dshell/src/functions/env.dart';
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_file_system.dart';

String TEST_DIR = 'path_test';
void main() {
  Settings().debug_on = true;

  t.group('Directory Path manipulation testing', () {
    t.test('absolute', () {
      TestFileSystem().withinZone((fs) {
        var paths = setup(fs);
        var cwd = pwd;
        t.expect(absolute(paths.pathTestDir),
            t.equals(join(cwd, paths.pathTestDir)));
      });
    });

    t.test('parent', () {
      TestFileSystem().withinZone((fs) {
        var paths = setup(fs);
        t.expect(dirname(paths.pathTestDir), t.equals(join(fs.root, TEST_DIR)));
      });
    });

    t.test('extension', () {
      TestFileSystem().withinZone((fs) {
        var paths = setup(fs);
        t.expect(extension(join(paths.pathTestDir, paths.testFile)),
            t.equals(paths.testExtension));
      });
    });

    t.test('basename', () {
      TestFileSystem().withinZone((fs) {
        var paths = setup(fs);
        t.expect(basename(join(paths.pathTestDir, paths.testFile)),
            t.equals(paths.testFile));
      });
    });

    t.test('PWD', () {
      TestFileSystem().withinZone((fs) {
        t.expect(pwd, t.equals(Directory.current.path));
      });
    });
  });
}

class Paths {
  String home;
  String pathTestDir;
  String testExtension;
  String testBaseName;
  String testFile;

  Paths(TestFileSystem fs) {
    home = HOME;
    pathTestDir = join(fs.root, TEST_DIR, 'pathTestDir');
    testExtension = '.jpg';
    testBaseName = 'fred';
    testFile = '$testBaseName$testExtension';
  }
}

Paths setup(TestFileSystem fs) {
  return Paths(fs);
}
