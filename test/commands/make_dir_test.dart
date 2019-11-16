import 'package:test/test.dart';
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;

  push(".");
  try {
    group("Directory Creation", () {
      String testDirectory = join(TEST_ROOT, "tmp_test");
      String testPath = join(TEST_ROOT, "tmp_test/longer/and/longer");

      test("Makedir", () {
        makeDir(testDirectory, createParent: true);

        expect(exists(testDirectory), equals(true));
      });

      test("Makedir with createParent", () {
        makeDir(testPath, createParent: true);

        expect(exists(testPath), equals(true));
      });

      test("removeDir", () {
        removeDir(testPath);

        expect(!exists(testPath), equals(true));
        expect(exists(parent(testPath)), equals(true));
      });

      test("Remove Dir recursive", () {
        removeDir(TEST_ROOT, recursive: true);
        expect(!exists(testDirectory), equals(true));
      });

      test("removeDir failure", () {
        expect(() => removeDir(testDirectory),
            throwsA(TypeMatcher<RemoveDirException>()));
      });

      test("makeDir createPath failure", () {
        expect(() => makeDir(testPath, createParent: false),
            throwsA(TypeMatcher<MakeDirException>()));
      });
    });
  } finally {
    pop();
  }
}
