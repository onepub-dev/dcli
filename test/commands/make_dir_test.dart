import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;

  push(".");
  try {
    t.group("Directory Creation", () {
      String testDirectory = join(TEST_ROOT, "tmp_test");
      String testPath = join(TEST_ROOT, "tmp_test/longer/and/longer");

      t.test("Makedir", () {
        makeDir(testDirectory, createParent: true);

        t.expect(exists(testDirectory), t.equals(true));
      });

      t.test("Makedir with createParent", () {
        makeDir(testPath, createParent: true);

        t.expect(exists(testPath), t.equals(true));
      });

      t.test("removeDir", () {
        removeDir(testPath);

        t.expect(!exists(testPath), t.equals(true));
        t.expect(exists(dirname(testPath)), t.equals(true));
      });

      t.test("Remove Dir recursive", () {
        removeDir(TEST_ROOT, recursive: true);
        t.expect(!exists(testDirectory), t.equals(true));
      });

      t.test("removeDir failure", () {
        t.expect(() => removeDir(testDirectory),
            t.throwsA(t.TypeMatcher<RemoveDirException>()));
      });

      t.test("makeDir createPath failure", () {
        t.expect(() => makeDir(testPath, createParent: false),
            t.throwsA(t.TypeMatcher<MakeDirException>()));
      });
    });
  } finally {
    pop();
  }
}
