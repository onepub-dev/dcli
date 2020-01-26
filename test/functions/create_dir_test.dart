import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_fs_zone.dart';
import '../util/test_paths.dart';

void main() {
  TestPaths();

  Settings().debug_on = true;

  t.group('Directory Creation', () {
    t.test('createDir', () {
      TestZone().run(() {
        var testDirectory = join(TestPaths.TEST_ROOT, 'tmp_test');

        createDir(testDirectory, recursive: true);

        t.expect(exists(testDirectory), t.equals(true));
      });
    });

    t.test('createDir with recursive', () {
      TestZone().run(() {
        var testPath = join(TestPaths.TEST_ROOT, 'tmp_test/longer/and/longer');
        createDir(testPath, recursive: true);

        t.expect(exists(testPath), t.equals(true));
      });
    });

    t.test('deleteDir', () {
      TestZone().run(() {
        var testPath = join(TestPaths.TEST_ROOT, 'tmp_test/longer/and/longer');
        deleteDir(testPath);

        t.expect(!exists(testPath), t.equals(true));
        t.expect(exists(dirname(testPath)), t.equals(true));
      });
    });

    t.test('Delete Dir recursive', () {
      TestZone().run(() {
        var testDirectory = join(TestPaths.TEST_ROOT, 'tmp_test');
        deleteDir(TestPaths.TEST_ROOT, recursive: true);
        t.expect(!exists(testDirectory), t.equals(true));
      });
    });

    t.test('deleteDir failure', () {
      TestZone().run(() {
        var testDirectory = join(TestPaths.TEST_ROOT, 'tmp_test');
        t.expect(() => deleteDir(testDirectory),
            t.throwsA(t.TypeMatcher<DeleteDirException>()));
      });
    });

    t.test('createDir createPath failure', () {
      TestZone().run(() {
        var testPath = join(TestPaths.TEST_ROOT, 'tmp_test/longer/and/longer');
        t.expect(() => createDir(testPath, recursive: false),
            t.throwsA(t.TypeMatcher<CreateDirException>()));
      });
    });
  });
}
