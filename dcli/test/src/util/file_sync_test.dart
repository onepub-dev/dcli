/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  group('FileSync', () {
    test('createTempFilename', () async {
      final file = createTempFilename();
      expect(exists(file), isFalse);
      expect(file.startsWith(Directory.systemTemp.path), isTrue);
      touch(file, create: true);
      expect(exists(file), isTrue);
      delete(file);
    });
    test('createTempFile', () async {
      final file = createTempFile();
      expect(exists(file), isTrue);
      expect(file.startsWith(Directory.systemTemp.path), isTrue);
      delete(file);
    });

    test('withTempFile', () async {
      final file = await withTempFileAsync((tempFile) async {
        expect(exists(tempFile), isTrue);
        expect(tempFile.startsWith(Directory.systemTemp.path), isTrue);
        return tempFile;
      });
      expect(exists(file), isFalse);
    });

    test('withTempFile - int', () async {
      final count = await withTempFileAsync((tempFile) async {
        expect(exists(tempFile), isTrue);
        expect(tempFile.startsWith(Directory.systemTemp.path), isTrue);
        return 5;
      });
      expect(count, equals(5));
    });

    test('withTempFile - suffix', () async {
      final count = await withTempFileAsync(
        (tempFile) async {
          expect(exists(tempFile), isTrue);
          expect(tempFile.startsWith(Directory.systemTemp.path), isTrue);
          expect(extension(tempFile), equals('.dodo'));
          return 5;
        },
        suffix: 'dodo',
      );
      expect(count, equals(5));
    });

    test('withTempFile - keep', () async {
      final tempFile = await withTempFileAsync(
        (tempFile)async {
          expect(exists(tempFile), isTrue);
          return tempFile;
        },
        suffix: 'dodo',
        keep: true,
      );
      expect(exists(tempFile), isTrue);
    });
  });

  group('symlinks', () {
    test('resolveSymlink', () async {
      await withTempDirAsync((dir) async {
        expect(isDirectory(dir), isTrue);

        await withTempFileAsync((file) async {
          file.write('Hello World');
          expect(exists(file), isTrue);
          final pathToLink = join(dir, 'link');
          createSymLink(targetPath: file, linkPath: pathToLink);
          expect(exists(pathToLink), isTrue);
          expect(isLink(pathToLink), isTrue);

          expect(resolveSymLink(pathToLink), equals(canonicalize(file)));
        }, pathToTempDir: dir);
      });
    });

    test('missing target', () async {
      await withTempDirAsync((dir) async {
        expect(isDirectory(dir), isTrue);

        await withTempFileAsync((file) async {
          file.write('Hello World');
          expect(exists(file), isTrue);
          final pathToLink = join(dir, 'link');
          createSymLink(targetPath: file, linkPath: pathToLink);
          expect(exists(pathToLink), isTrue);
          expect(isLink(pathToLink), isTrue);

          delete(file);

          /// target is misisng so should throw an exception.
          expect(() => resolveSymLink(pathToLink),
              throwsA(isA<FileSystemException>()));
        }, pathToTempDir: dir);
      });
    });

    test('delete symlink', () async {
      await withTempDirAsync((dir) async {
        expect(isDirectory(dir), isTrue);

        await withTempFileAsync((file) async {
          file.write('Hello World');
          expect(exists(file), isTrue);
          final pathToLink = join(dir, 'link');
          createSymLink(targetPath: file, linkPath: pathToLink);
          expect(exists(pathToLink), isTrue);
          expect(isLink(pathToLink), isTrue);

          deleteSymlink(pathToLink);
          expect(exists(pathToLink), isFalse);
        }, pathToTempDir: dir);
      });
    });
  });
}
