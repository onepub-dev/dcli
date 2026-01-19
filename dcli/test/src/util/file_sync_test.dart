/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteDirException)
/// @Throwing(DeleteException)
/// @Throwing(RangeError)
/// @Throwing(TouchException)
void main() {
  group('FileSync', () {
    test('createTempFilename', () {
      final file = createTempFilename();
      expect(exists(file), isFalse);
      expect(file.startsWith(Directory.systemTemp.path), isTrue);
      touch(file, create: true);
      expect(exists(file), isTrue);
      delete(file);
    });
    test('createTempFile', () {
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
        (tempFile) async {
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
