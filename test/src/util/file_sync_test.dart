import 'dart:io';

import 'package:dcli/dcli.dart' hide equals;
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
      final file = withTempFile((tempFile) {
        expect(exists(tempFile), isTrue);
        expect(tempFile.startsWith(Directory.systemTemp.path), isTrue);
        return tempFile;
      });
      expect(exists(file), isFalse);
    });

    test('withTempFile - int', () async {
      final count = withTempFile((tempFile) {
        expect(exists(tempFile), isTrue);
        expect(tempFile.startsWith(Directory.systemTemp.path), isTrue);
        return 5;
      });
      expect(count, equals(5));
    });

    test('withTempFile - suffix', () async {
      final count = withTempFile(
        (
          tempFile,
        ) {
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
      final tempFile = withTempFile(
        (
          tempFile,
        ) {
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
    test('resolveSymlink', () {
      withTempDir((dir) {
        expect(isDirectory(dir), isTrue);

        withTempFile((file) {
          file.write('Hello World');
          expect(exists(file), isTrue);
          final pathToLink = join(dir, 'link');
          symlink(file, pathToLink);
          expect(exists(pathToLink), isTrue);
          expect(isLink(pathToLink), isTrue);

          expect(resolveSymLink(pathToLink), equals(canonicalize(file)));
        }, pathToTempDir: dir);
      });
    });

    test('missing target', () {
      withTempDir((dir) {
        expect(isDirectory(dir), isTrue);

        withTempFile((file) {
          file.write('Hello World');
          expect(exists(file), isTrue);
          final pathToLink = join(dir, 'link');
          symlink(file, pathToLink);
          expect(exists(pathToLink), isTrue);
          expect(isLink(pathToLink), isTrue);

          delete(file);

          /// target is misisng so should throw an exception.
          expect(() => resolveSymLink(pathToLink),
              throwsA(isA<FileSystemException>()));
        }, pathToTempDir: dir);
      });
    });

    test('delete symlink', () {
      withTempDir((dir) {
        expect(isDirectory(dir), isTrue);

        withTempFile((file) {
          file.write('Hello World');
          expect(exists(file), isTrue);
          final pathToLink = join(dir, 'link');
          symlink(file, pathToLink);
          expect(exists(pathToLink), isTrue);
          expect(isLink(pathToLink), isTrue);

          deleteSymlink(pathToLink);
          expect(exists(pathToLink), isFalse);
        }, pathToTempDir: dir);
      });
    });
  });
}
