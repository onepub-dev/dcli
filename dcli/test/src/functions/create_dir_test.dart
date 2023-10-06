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

void main() {
  t.group('Directory Creation', () {
    t.test('createDir', () async {
      await withTempDir((testRoot) async {
        final testDirectory = join(testRoot, 'test');
        createDir(testDirectory, recursive: true);

        t.expect(exists(testDirectory), t.equals(true));
        deleteDir(testDirectory);
      });
    });

    t.test('createDir with recursive', () async {
      await withTempDir((testRoot) async {
        final testPath = join(testRoot, 'tmp_test/longer/and/longer');
        createDir(testPath, recursive: true);

        t.expect(exists(testPath), t.equals(true));
        deleteDir(join(testRoot, 'tmp_test'));
      });
    });

    t.test('deleteDir', () async {
      await withTempDir((testRoot) async {
        final testPath = join(testRoot, 'tmp_test/longer/and/longer');
        createDir(testPath, recursive: true);
        deleteDir(testPath);

        t.expect(!exists(testPath), t.equals(true));
        t.expect(exists(dirname(testPath)), t.equals(true));
        deleteDir(join(testRoot, 'tmp_test'));
      });
    });

    t.test('Delete Dir recursive', () async {
      await withTempDir((testRoot) async {
        final testDirectory = join(testRoot, 'tmp_test');
        createDir(testDirectory);
        deleteDir(testDirectory);
        t.expect(!exists(testDirectory), t.equals(true));
      });
    });

    t.test('deleteDir failure', () async {
      await withTempDir((testRoot) async {
        final testDirectory = join(testRoot, 'tmp_test');
        t.expect(
          () => deleteDir(testDirectory),
          t.throwsA(isA<DeleteDirException>()),
        );
      });
    });

    t.test('createDir createPath failure', () async {
      await withTempDir((testRoot) async {
        final testPath = join(testRoot, 'tmp_test/longer/and/longer');
        t.expect(
          () => createDir(testPath),
          t.throwsA(isA<CreateDirException>()),
        );
      });
    });

    t.test('createTempDir', () {
      final tempDir = createTempDir();
      expect(exists(tempDir), isTrue);
    });

    t.test('withTempDir', () async {
      final dir = await withTempDir((tempDir) async {
        expect(exists(tempDir), isTrue);
        touch(join(tempDir, 'test.txt'), create: true);
        createDir(join(tempDir, 'test2'));

        return tempDir;
      });

      expect(exists(dir), isFalse);
    });

    t.test('withTempDir - keep', () async {
      final dir = await withTempDir(
        (tempDir) async {
          expect(exists(tempDir), isTrue);

          return tempDir;
        },
        keep: true,
      );

      expect(exists(dir), isTrue);
    });
  });
}
