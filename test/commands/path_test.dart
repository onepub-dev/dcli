import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;
  String cwd = pwd;
  String TEST_DIR = "path_test";

  try {
    t.group("Directory Path manipulation testing", () {
      String home = env("HOME");
      String pathTestDir = join(TEST_ROOT, TEST_DIR, "pathTestDir");
      String testExtension = ".jpg";
      String testBaseName = "fred";
      String testFile = "$testBaseName$testExtension";

      t.test("absolute", () {
        String cwd = pwd;

        t.expect(absolute(pathTestDir), t.equals(join(cwd, pathTestDir)));
      });

      t.test("parent", () {
        t.expect(dirname(pathTestDir), t.equals(join(TEST_ROOT, TEST_DIR)));
      });

      t.test("extension", () {
        t.expect(
            extension(join(pathTestDir, testFile)), t.equals(testExtension));
      });

      t.test("basename", () {
        t.expect(basename(join(pathTestDir, testFile)), t.equals(testFile));
      });

      t.test("PWD", () {
        t.expect(pwd, t.startsWith(home));
      });

      t.test("CD", () {
        String testdir = pwd;

        makeDir("cd_test");
        cd("cd_test");
        t.expect(pwd, t.equals(absolute(join(testdir, "cd_test"))));
        cd("..");
        t.expect(pwd, t.equals(absolute(cwd)));

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

        removeDir(pathTestDir, recursive: true);
      });

      t.test("Too many pops", () {
        t.expect(() => pop(), t.throwsA(t.TypeMatcher<PopException>()));
      });
    });
  } finally {
    cd(cwd);
  }
}
