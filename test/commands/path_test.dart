import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;
  String cwd = pwd;

  try {
    t.group("Directory Path manipulation testing", () {
      String home = env("HOME");
      String pathTestDir = join(TEST_ROOT, "pathTestDir");
      String testExtension = "jpg";
      String testBaseName = "fred";
      String testFile = "$testBaseName.$testExtension";

      t.test("absolute", () {
        String cwd = pwd;

        t.expect(absolute(pathTestDir), t.equals(join(cwd, pathTestDir)));
      });

      t.test("parent", () {
        t.expect(dirname(pathTestDir), t.equals(absolute(TEST_ROOT)));
      });

      t.test("extension", () {
        t.expect(
            extension(join(pathTestDir, testFile)), t.equals(testExtension));
      });

      t.test("basename", () {
        t.expect(basename(join(pathTestDir, testFile)), t.equals(testBaseName));
      });

      t.test("PWD", () {
        t.expect(pwd, t.startsWith(home));
      });

      t.test("CD", () {
        cd("..");
        t.expect(pwd, t.equals(dirname(cwd)));

        cd(cwd);
        t.expect(pwd, t.equals(cwd));
      });

      t.test("Push/Pop", () {
        String start = pwd;
        makeDir(pathTestDir, createParent: true);

        String expectedPath = absolute(pathTestDir);
        push(pathTestDir);
        t.expect(pwd, t.equals(expectedPath));

        pop();
        t.expect(pwd, t.equals(start));

        removeDir(TEST_ROOT, recursive: true);
      });

      t.test("Too many pops", () {
        t.expect(() => pop(), t.throwsA(t.TypeMatcher<PopException>()));
      });
    });
  } finally {
    cd(cwd);
  }
}
