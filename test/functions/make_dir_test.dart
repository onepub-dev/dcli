import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;

  t.group("Directory Creation", () {
    String testDirectory = join(TEST_ROOT, "tmp_test");
    String testPath = join(TEST_ROOT, "tmp_test/longer/and/longer");

    t.test("Makedir", () {
      createDir(testDirectory, recursive: true);

      t.expect(exists(testDirectory), t.equals(true));
    });

    t.test("Makedir with createParent", () {
      createDir(testPath, recursive: true);

      t.expect(exists(testPath), t.equals(true));
    });

    t.test("deleteDir", () {
      deleteDir(testPath);

      t.expect(!exists(testPath), t.equals(true));
      t.expect(exists(dirname(testPath)), t.equals(true));
    });

    t.test("Delete Dir recursive", () {
      deleteDir(TEST_ROOT, recursive: true);
      t.expect(!exists(testDirectory), t.equals(true));
    });

    t.test("deleteDir failure", () {
      t.expect(() => deleteDir(testDirectory),
          t.throwsA(t.TypeMatcher<DeleteDirException>()));
    });

    t.test("createDir createPath failure", () {
      t.expect(() => createDir(testPath, recursive: false),
          t.throwsA(t.TypeMatcher<CreateDirException>()));
    });
  });
}
