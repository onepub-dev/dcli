/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:test/test.dart' as t;

void main() {
  t.group('FileSync', () {
    t.test('Append', () async {
      await withTempDirAsync((fsRoot) async {
        final testFile = join(fsRoot, 'lines.txt');

        if (exists(testFile)) {
          delete(testFile);
        }
        final fstat = withOpenFile(testFile, (file) {
          for (var i = 0; i < 10; i++) {
            file.append('Line $i is here');
          }
          return stat(file.path);
        });

        // windows us \r\n vs posix \n
        t.expect(fstat.size, t.equals(Settings().isWindows ? 160 : 150));
      });
    });

    t.test('Write', () async {
      await withTempDirAsync((fsRoot) async {
        final testFile = join(fsRoot, 'lines.txt');
        if (exists(testFile)) {
          delete(testFile);
        }
        const replacement = 'This is all that should be left';
        final fstat = withOpenFile(testFile, (file) {
          for (var i = 0; i < 10; i++) {
            file.append('Line $i is here');
          }

          file.write(replacement, newline: '');

          return stat(file.path);
        });

        t.expect(fstat.size, t.equals(replacement.length));
      });
    });
  });
}
