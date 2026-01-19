/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart';
import 'package:test/test.dart' as t;

/// @Throwing(ArgumentError)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteDirException)
void main() {
  t.group(
    'Head',
    () {
      t.test('head 5', () async {
        await withTempDirAsync((fsRoot) async {
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
