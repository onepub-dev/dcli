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
      final count = withTempFile((
        tempFile,
      ) {
        expect(exists(tempFile), isTrue);
        expect(tempFile.startsWith(Directory.systemTemp.path), isTrue);
        expect(extension(tempFile), equals('.dodo'));
        return 5;
      }, suffix: 'dodo');
      expect(count, equals(5));
    });

    test('withTempFile - keep', () async {
      final tempFile = withTempFile((
        tempFile,
      ) {
        expect(exists(tempFile), isTrue);
        return tempFile;
      }, suffix: 'dodo', keep: true);
      expect(exists(tempFile), isTrue);
    });
  });
}
