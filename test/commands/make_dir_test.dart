import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;

  t.group("Directory Creation", () {
    String testDirectory = join(TEST_ROOT, "tmp_test");
    String testPath = join(TEST_ROOT, "tmp_test/longer/and/longer");

    t.test("Makedir", () {
      createDir(testDirectory, createParent: true);

      t.expect(exists(testDirectory), t.equals(true));
    });

    t.test("Makedir with createParent", () {
      createDir(testPath, createParent: true);

      t.expect(exists(testPath), t.equals(true));
    });

    t.test("removeDir", () {
      deleteDir(testPath);

      t.expect(!exists(testPath), t.equals(true));
      t.expect(exists(dirname(testPath)), t.equals(true));
    });

    t.test("Remove Dir recursive", () {
      deleteDir(TEST_ROOT, recursive: true);
      t.expect(!exists(testDirectory), t.equals(true));
    });

    t.test("removeDir failure", () {
      t.expect(() => deleteDir(testDirectory),
          t.throwsA(t.TypeMatcher<RemoveDirException>()));
    });

    t.test("makeDir createPath failure", () {
      t.expect(() => createDir(testPath, createParent: false),
          t.throwsA(t.TypeMatcher<MakeDirException>()));
    });
  });
}
