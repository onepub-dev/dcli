@Timeout(Duration(seconds: 600))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:test/test.dart' as t;
import 'package:test/test.dart';

void main() {
  t.group('Delete', () {
    t.test('delete ', () {
      withTempDir((fsRoot) {
        final testFile = join(fsRoot, 'lines.txt');
        if (!exists(dirname(testFile))) {
          createDir(dirname(testFile), recursive: true);
        }

        touch(testFile, create: true);

        delete(testFile);
        t.expect(!exists(testFile), t.equals(true));
      });
    });

    t.test('delete non-existing ', () {
      withTempDir((fsRoot) {
        final testFile = join(fsRoot, 'lines.txt');
        touch(testFile, create: true);
        delete(testFile);

        t.expect(() => delete(testFile), t.throwsA(isA<DeleteException>()));
      });
    });
  });
}
