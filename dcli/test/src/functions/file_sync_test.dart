/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart';
import 'package:test/test.dart' as t;

void main() {
  t.group('FileSync', () {
    t.test('Append', () async {
      await withTempDir((fsRoot) async {
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
        t.expect(fstat.size, t.equals(core.Settings().isWindows ? 160 : 150));
      });
    });

    t.test('Write', () async {
      await withTempDir((fsRoot) async {
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
