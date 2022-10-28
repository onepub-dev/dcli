/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart' ;
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart' hide isEmpty;

import '../util/test_file_system.dart';

void main() {
  group(
    'iswritable',
    () {
      withTempDir((fsRoot) {
        TestFileSystem.buildDirectoryTree(fsRoot);
// owner, group, world, read, write execute

        test('owner', () {
          withTempFile((one) {
            touch(one, create: true);
            'chmod 200 $one'.run;
            expect(isWritable(one), equals(true));
            'chmod 000 $one'.run;
            expect(isWritable(one), equals(false));
            expect(isReadable(one), equals(false));
            expect(isExecutable(one), equals(false));
          });
        });

        test('group', () {
          withTempFile((one) {
            touch(one, create: true);
            'chmod 020 $one'.run;
            expect(isWritable(one), equals(true));
            'chmod 000 $one'.run;
            expect(isWritable(one), equals(false));
            expect(isReadable(one), equals(false));
            expect(isExecutable(one), equals(false));
          });
        });

        test('world', () {
          withTempFile((one) {
            touch(one, create: true);
            'chmod 002 $one'.run;
            expect(isWritable(one), equals(true));
            'chmod 000 $one'.run;
            expect(isWritable(one), equals(false));
            expect(isReadable(one), equals(false));
            expect(isExecutable(one), equals(false));
          });
        });
      });
    },
    skip: core.Settings().isWindows,
  );

  group(
    'isReadable',
    () {
      test('owner', () {
        withTempFile((one) {
          touch(one, create: true);
          'chmod 400 $one'.run;
          expect(isReadable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isReadable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isExecutable(one), equals(false));
        });
      });

      test('group', () {
        withTempFile((one) {
          touch(one, create: true);
          'chmod 040 $one'.run;
          expect(isReadable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isReadable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isExecutable(one), equals(false));
        });
      });

      test('world', () {
        withTempFile((one) {
          touch(one, create: true);
          'chmod 004 $one'.run;
          expect(isReadable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isReadable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isExecutable(one), equals(false));
        });
      });
    },
    skip: core.Settings().isWindows,
  );

  group(
    'isExecutable',
    () {
      test('owner', () {
        withTempFile((one) {
          touch(one, create: true);
          'chmod 100 $one'.run;
          expect(isExecutable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isExecutable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isReadable(one), equals(false));
        });
      });

      test('group', () {
        withTempFile((one) {
          touch(one, create: true);
          'chmod 010 $one'.run;
          expect(isExecutable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isExecutable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isReadable(one), equals(false));
        });
      });

      test('world', () {
        withTempFile((one) {
          touch(one, create: true);
          'chmod 001 $one'.run;
          expect(isExecutable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isExecutable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isReadable(one), equals(false));
        });
      });
    },
    skip: core.Settings().isWindows,
  );

  group('isEmpty', () {
    test('isEmpty - good', () {
      withTempDir((root) {
        final root = createTempDir();

        expect(isEmpty(root), isTrue);

        touch(join(root, 'a file'), create: true);

        expect(isEmpty(root), isFalse);
      });
    });
  });

  group('isFileType', () {
    test('isFile', () {
      withTempFile((file) {
        expect(isFile(file), isTrue);
      });
    });

    test('isDirectory', () {
      withTempDir((dir) {
        expect(isDirectory(dir), isTrue);
      });
    });

    test('isLink', () {
      withTempDir((dir) {
        expect(isDirectory(dir), isTrue);

        withTempFile((file) {
          file.write('Hello World');
          expect(exists(file), isTrue);
          final pathToLink = join(dir, 'link');
          symlink(file, pathToLink);
          expect(exists(pathToLink), isTrue);
          expect(isLink(pathToLink), isTrue);
        }, pathToTempDir: dir);
      });
    });
  });
}
