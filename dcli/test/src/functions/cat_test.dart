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

import '../util/test_utils.dart';

late String testFile;
void main() {
  t.group('Cat', () {
    // Don't know how to test this as it writes directly to stdout.
    // Need some way to hook Stdout
    t.test('Cat good ', () async {
      await withTempDirAsync((testRoot) async {
        print('PWD $pwd');
        testFile = join(testRoot, 'lines.txt');
        createLineFile(testFile, 10);

        final lines = <String?>[];
        cat(testFile, stdout: lines.add);
        t.expect(lines.length, t.equals(10));
      });
    });

    t.test('cat non-existing ', () async {
      await withTempDirAsync((testRoot) async {
        t.expect(() => cat('bad file.text'), t.throwsA(isA<CatException>()));
      });
    });
  });
}
