import 'dart:io';

import 'package:dshell/src/functions/env.dart';
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_fs_zone.dart';
import '../util/test_paths.dart';

String TEST_DIR = 'path_test';
void main() {
  TestPaths();
  
  
  Settings().debug_on = true;

  t.group('Directory Path manipulation testing', () {
    t.test('absolute', () {
      TestZone().run(() {
        var paths = setup();
        var cwd = pwd;
        t.expect(absolute(paths.pathTestDir),
            t.equals(join(cwd, paths.pathTestDir)));
      });
    });

    t.test('parent', () {
      TestZone().run(() {
        var paths = setup();
        t.expect(dirname(paths.pathTestDir),
            t.equals(join(TestPaths.TEST_ROOT, TEST_DIR)));
      });
    });

    t.test('extension', () {
      TestZone().run(() {
        var paths = setup();
        t.expect(extension(join(paths.pathTestDir, paths.testFile)),
            t.equals(paths.testExtension));
      });
    });

    t.test('basename', () {
      TestZone().run(() {
        var paths = setup();
        t.expect(basename(join(paths.pathTestDir, paths.testFile)),
            t.equals(paths.testFile));
      });
    });

    t.test('PWD', () {
      TestZone().run(() {
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

  Paths() {
    home = HOME;
    pathTestDir = join(TestPaths.TEST_ROOT, TEST_DIR, 'pathTestDir');
    testExtension = '.jpg';
    testBaseName = 'fred';
    testFile = '$testBaseName$testExtension';
  }
}

Paths setup() {
  return Paths();
}
