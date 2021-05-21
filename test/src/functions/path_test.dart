@t.Timeout(Duration(seconds: 600))
import 'dart:io';

import 'package:dcli/src/functions/env.dart';
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';

String _testDir = 'path_test';
void main() {
  t.group('Directory Path manipulation testing', () {
    t.test('absolute', () {
      withTempDir((fsRoot) {
        final paths = setup(fsRoot);
        final cwd = pwd;
        t.expect(absolute(paths.pathTestDir!),
            t.equals(join(cwd, paths.pathTestDir)));
      });
    });

    t.test('parent', () {
      withTempDir((fsRoot) {
        final paths = setup(fsRoot);
        t.expect(dirname(paths.pathTestDir!), t.equals(join(fsRoot, _testDir)));
      });
    });

    t.test('extension', () {
      withTempDir((fsRoot) {
        final paths = setup(fsRoot);
        t.expect(extension(join(paths.pathTestDir!, paths.testFile)),
            t.equals(paths.testExtension));
      });
    });

    t.test('basename', () {
      withTempDir((fsRoot) {
        final paths = setup(fsRoot);
        t.expect(basename(join(paths.pathTestDir!, paths.testFile)),
            t.equals(paths.testFile));
      });
    });

    t.test('PWD', () {
      withTempDir((fsRoot) {
        t.expect(pwd, t.equals(Directory.current.path));
      });
    });
  });
}

class Paths {
  Paths(String fsRoot) {
    home = HOME;
    pathTestDir = join(fsRoot, _testDir, 'pathTestDir');
    testExtension = '.jpg';
    testBaseName = 'fred';
    testFile = '$testBaseName$testExtension';
  }

  String? home;
  String? pathTestDir;
  String? testExtension;
  String? testBaseName;
  String? testFile;
}

Paths setup(String fs) => Paths(fs);
