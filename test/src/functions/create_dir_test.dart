@Timeout(Duration(seconds: 600))

import 'package:dcli/dcli.dart';
import 'package:test/test.dart' as t;
import 'package:test/test.dart';

void main() {
  t.group('Directory Creation', () {
    t.test('createDir', () {
      withTempDir((testRoot) {
        final testDirectory = join(testRoot, 'test');
        createDir(testDirectory, recursive: true);

        t.expect(exists(testDirectory), t.equals(true));
        deleteDir(testDirectory);
      });
    });

    t.test('createDir with recursive', () {
      withTempDir((testRoot) {
        final testPath = join(testRoot, 'tmp_test/longer/and/longer');
        createDir(testPath, recursive: true);

        t.expect(exists(testPath), t.equals(true));
        deleteDir(join(testRoot, 'tmp_test'));
      });
    });

    t.test('deleteDir', () {
      withTempDir((testRoot) {
        final testPath = join(testRoot, 'tmp_test/longer/and/longer');
        createDir(testPath, recursive: true);
        deleteDir(testPath);

        t.expect(!exists(testPath), t.equals(true));
        t.expect(exists(dirname(testPath)), t.equals(true));
        deleteDir(join(testRoot, 'tmp_test'));
      });
    });

    t.test('Delete Dir recursive', () {
      withTempDir((testRoot) {
        final testDirectory = join(testRoot, 'tmp_test');
        createDir(testDirectory);
        deleteDir(testDirectory);
        t.expect(!exists(testDirectory), t.equals(true));
      });
    });

    t.test('deleteDir failure', () {
      withTempDir((testRoot) {
        final testDirectory = join(testRoot, 'tmp_test');
        t.expect(() => deleteDir(testDirectory),
            t.throwsA(isA<DeleteDirException>()));
      });
    });

    t.test('createDir createPath failure', () {
      withTempDir((testRoot) {
        final testPath = join(testRoot, 'tmp_test/longer/and/longer');
        t.expect(
            () => createDir(testPath), t.throwsA(isA<CreateDirException>()));
      });
    });

    t.test('createTempDir', () {
      final tempDir = createTempDir();
      expect(exists(tempDir), isTrue);
    });

    t.test('withTempDir', () {
      final dir = withTempDir((tempDir) {
        expect(exists(tempDir), isTrue);
        touch(join(tempDir, 'test.txt'), create: true);
        createDir(join(tempDir, 'test2'));

        return tempDir;
      });

      expect(exists(dir), isFalse);
    });

    t.test('withTempDir - keep', () {
      final dir = withTempDir((tempDir) {
        expect(exists(tempDir), isTrue);

        return tempDir;
      }, keep: true);

      expect(exists(dir), isTrue);
    });
  });
}
