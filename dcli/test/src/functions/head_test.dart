/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:test/test.dart' as t;

import '../util/test_file_system.dart';

void main() {
  t.group(
    'Head',
    () {
      t.test('head 5', () {
        withTempDir((fsRoot) {
          TestFileSystem.buildDirectoryTree(fsRoot);
          final testFile = join(fsRoot, 'lines.txt');
          if (exists(testFile)) {
            delete(testFile);
          }
          if (!exists(fsRoot)) {
            createDir(fsRoot, recursive: true);
          }
          withOpenFile(testFile, (file) {
            for (var i = 0; i < 10; i++) {
              file.append('Line $i is here');
            }
          });

          final lines = head(testFile, 5).toList();

          t.expect(lines.length, t.equals(5));
        });
      });
    },
    // calling head().toList() fails as we end up with two progressions.
    skip: true,
  );
}
