@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:test/test.dart' as t;
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteDirException)
/// @Throwing(TouchException)
void main() {
  t.group('Delete', () {
    t.test('delete ', () async {
      await withTempDirAsync((fsRoot) async {
        final testFile = join(fsRoot, 'lines.txt');
        if (!exists(dirname(testFile))) {
          createDir(dirname(testFile), recursive: true);
        }

        touch(testFile, create: true);

        delete(testFile);
        t.expect(!exists(testFile), t.equals(true));
      });
    });

    t.test('delete non-existing ', () async {
      await withTempDirAsync((fsRoot) async {
        final testFile = join(fsRoot, 'lines.txt');
        touch(testFile, create: true);
        delete(testFile);

        t.expect(() => delete(testFile), t.throwsA(isA<DeleteException>()));
      });
    });
  });
}
