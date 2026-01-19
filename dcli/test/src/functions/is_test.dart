/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart' hide isEmpty;

/// @Throwing(ArgumentError)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteDirException)
/// @Throwing(DeleteException)
/// @Throwing(core.TouchException)
void main() {
  group(
    'iswritable',
    () {
      test('owner', () async {
        await withTempDirAsync((fsRoot) async {
          TestFileSystem.buildDirectoryTree(fsRoot);
          await withTempFileAsync((one) async {
            touch(one, create: true);
            'chmod 200 $one'.run;
            expect(isWritable(one), equals(true));
            'chmod 000 $one'.run;
            expect(isWritable(one), equals(false));
            expect(isReadable(one), equals(false));
            expect(isExecutable(one), equals(false));
          });
        });
      });

      test('group', () async {
        await withTempDirAsync((fsRoot) async {
          TestFileSystem.buildDirectoryTree(fsRoot);
          await withTempFileAsync((one) async {
            touch(one, create: true);
            'chmod 020 $one'.run;
            expect(isWritable(one), equals(true));
            'chmod 000 $one'.run;
            expect(isWritable(one), equals(false));
            expect(isReadable(one), equals(false));
            expect(isExecutable(one), equals(false));
          });
        });
      });

      test('world', () async {
        await withTempDirAsync((fsRoot) async {
          TestFileSystem.buildDirectoryTree(fsRoot);
          await withTempFileAsync((one) async {
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
      test('owner', () async {
        await withTempFileAsync((one) async {
          touch(one, create: true);
          'chmod 400 $one'.run;
          expect(isReadable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isReadable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isExecutable(one), equals(false));
        });
      });

      test('group', () async {
        await withTempFileAsync((one) async {
          touch(one, create: true);
          'chmod 040 $one'.run;
          expect(isReadable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isReadable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isExecutable(one), equals(false));
        });
      });

      test('world', () async {
        await withTempFileAsync((one) async {
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
      test('owner', () async {
        await withTempFileAsync((one) async {
          touch(one, create: true);
          'chmod 100 $one'.run;
          expect(isExecutable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isExecutable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isReadable(one), equals(false));
        });
      });

      test('group', () async {
        await withTempFileAsync((one) async {
          touch(one, create: true);
          'chmod 010 $one'.run;
          expect(isExecutable(one), equals(true));
          'chmod 000 $one'.run;
          expect(isExecutable(one), equals(false));
          expect(isWritable(one), equals(false));
          expect(isReadable(one), equals(false));
        });
      });

      test('world', () async {
        await withTempFileAsync((one) async {
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
    test('isEmpty - good', () async {
      await withTempDirAsync((root) async {
        final root = createTempDir();

        expect(isEmpty(root), isTrue);

        touch(join(root, 'a file'), create: true);

        expect(isEmpty(root), isFalse);
      });
    });
  });

  group('isFileType', () {
    test('isFile', () async {
      await withTempFileAsync((file) async {
        expect(isFile(file), isTrue);
      });
    });

    test('isDirectory', () async {
      await withTempDirAsync((dir) async {
        expect(isDirectory(dir), isTrue);
      });
    });

    test('isLink', () async {
      await withTempDirAsync((dir) async {
        expect(isDirectory(dir), isTrue);

        await withTempFileAsync((file) async {
          file.write('Hello World');
          expect(exists(file), isTrue);
          final pathToLink = join(dir, 'link');
          createSymLink(targetPath: file, linkPath: pathToLink);
          expect(exists(pathToLink), isTrue);
          expect(isLink(pathToLink), isTrue);
        }, pathToTempDir: dir);
      });
    });
  });
}
