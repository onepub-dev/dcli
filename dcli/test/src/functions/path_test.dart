@t.Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:test/test.dart' as t;

var _testDir = 'path_test';

/// @Throwing(ArgumentError)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteDirException)
/// @Throwing(RangeError)
void main() {
  t.group('Directory Path manipulation testing', () {
    t.test('absolute', () async {
      await withTempDirAsync((fsRoot) async {
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

    t.test('parent', () async {
      await withTempDirAsync((fsRoot) async {
        final paths = setup(fsRoot);
        t.expect(dirname(paths.pathTestDir!), t.equals(join(fsRoot, _testDir)));
      });
    });

    t.test('extension', () async {
      await withTempDirAsync((fsRoot) async {
        final paths = setup(fsRoot);
        t.expect(
          extension(join(paths.pathTestDir!, paths.testFile)),
          t.equals(paths.testExtension),
        );
      });
    });

    t.test('basename', () async {
      await withTempDirAsync((fsRoot) async {
        final paths = setup(fsRoot);
        t.expect(
          basename(join(paths.pathTestDir!, paths.testFile)),
          t.equals(paths.testFile),
        );
      });
    });

    t.test('PWD', () async {
      await withTempDirAsync((fsRoot) async {
        t.expect(pwd, t.equals(Directory.current.path));
      });
    });
  });
}

class Paths {
  String? home;

  String? pathTestDir;

  String? testExtension;

  String? testBaseName;

  String? testFile;

  /// @Throwing(ArgumentError)
  Paths(String fsRoot) {
    home = HOME;
    pathTestDir = join(fsRoot, _testDir, 'pathTestDir');
    testExtension = '.jpg';
    testBaseName = 'fred';
    testFile = '$testBaseName$testExtension';
  }
}

/// @Throwing(ArgumentError)
Paths setup(String fs) => Paths(fs);
