@Timeout(Duration(seconds: 600))
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('Directory Creation', () {
    t.test('createDir', () {
      TestFileSystem().withinZone((fs) {
        var testDirectory = join(fs.fsRoot, 'tmp_test');

        createDir(testDirectory, recursive: true);

        t.expect(exists(testDirectory), t.equals(true));
        deleteDir(testDirectory);
      });
    });

    t.test('createDir with recursive', () {
      TestFileSystem().withinZone((fs) {
        var testPath = join(fs.fsRoot, 'tmp_test/longer/and/longer');
        createDir(testPath, recursive: true);

        t.expect(exists(testPath), t.equals(true));
        deleteDir(join(fs.fsRoot, 'tmp_test'), recursive: true);
      });
    });

    t.test('deleteDir', () {
      TestFileSystem().withinZone((fs) {
        var testPath = join(fs.fsRoot, 'tmp_test/longer/and/longer');
        createDir(testPath, recursive: true);
        deleteDir(testPath);

        t.expect(!exists(testPath), t.equals(true));
        t.expect(exists(dirname(testPath)), t.equals(true));
        deleteDir(join(fs.fsRoot, 'tmp_test'), recursive: true);
      });
    });

    t.test('Delete Dir recursive', () {
      TestFileSystem().withinZone((fs) {
        var testDirectory = join(fs.fsRoot, 'tmp_test');
        createDir(testDirectory);
        deleteDir(testDirectory, recursive: true);
        t.expect(!exists(testDirectory), t.equals(true));
      });
    });

    t.test('deleteDir failure', () {
      TestFileSystem().withinZone((fs) {
        var testDirectory = join(fs.fsRoot, 'tmp_test');
        t.expect(() => deleteDir(testDirectory),
            t.throwsA(t.TypeMatcher<DeleteDirException>()));
      });
    });

    t.test('createDir createPath failure', () {
      TestFileSystem().withinZone((fs) {
        var testPath = join(fs.fsRoot, 'tmp_test/longer/and/longer');
        t.expect(() => createDir(testPath, recursive: false),
            t.throwsA(t.TypeMatcher<CreateDirException>()));
      });
    });
  });
}
