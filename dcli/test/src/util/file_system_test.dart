@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test(
    'MemoryFileSystem',
    () {
      withTempDir((fs) {
        // final fs = MemoryFileSystem();

        // fs.directory('/tmp').createSync();
        // assert(fs.statSync('/tmp').type != FileSystemEntityType.notFound);

        // fs.file('.');

        final restoreTo = Directory.current;

        print('root cwd: ${Directory.current}');

        print('testzone cwd: ${Directory.current}');

        Directory.current = rootPath;
        final dir = join(rootPath, 'tmp', 'mfs.test');
        // Directory(dir).createSync();
        if (!exists(dir)) {
          createDir(dir);
        }
        print('testzone post cwd: $pwd');

        Directory.current = restoreTo;
      });
    },
    skip: true,
  );
}
