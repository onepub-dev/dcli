@t.Timeout(Duration(seconds: 600))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:test/test.dart' as t;

String _testDir = 'path_test';
void main() {
  t.group('Directory Path manipulation testing', () {
    t.test('absolute', () {
      withTempDir((fsRoot) {
        final paths = setup(fsRoot);
        final cwd = pwd;
        t.expect(
          absolute(paths.pathTestDir!),
          t.equals(
            join(cwd, paths.pathTestDir),
          ),
        );
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
        t.expect(
          extension(join(paths.pathTestDir!, paths.testFile)),
          t.equals(paths.testExtension),
        );
      });
    });

    t.test('basename', () {
      withTempDir((fsRoot) {
        final paths = setup(fsRoot);
        t.expect(
          basename(join(paths.pathTestDir!, paths.testFile)),
          t.equals(paths.testFile),
        );
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
