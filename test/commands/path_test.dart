import 'package:test/test.dart';
import "package:dshell/dshell.dart";

import '../test_settings.dart';

void main() {
  Settings().debug_on = true;
  String cwd = pwd;

  try {
    group("Directory Path manipulation testing", () {
      String home = env("HOME");
      String pathTestDir = join(TEST_ROOT, "pathTestDir");
      String testExtension = "jpg";
      String testBaseName = "fred";
      String testFile = "$testBaseName.$testExtension";

      test("absolute", () {
        String cwd = pwd;

        expect(absolute(pathTestDir), equals(join(cwd, pathTestDir)));
      });

      test("parent", () {
        expect(parent(pathTestDir), equals(absolute(TEST_ROOT)));
      });

      test("filename", () {
        expect(filename(join(pathTestDir, testFile)), equals(testFile));
      });

      test("extension", () {
        expect(extension(join(pathTestDir, testFile)), equals(testExtension));
      });

      test("basename", () {
        expect(basename(join(pathTestDir, testFile)), equals(testBaseName));
      });

      test("PWD", () {
        expect(pwd, startsWith(home));
      });

      test("CD", () {
        cd("..");
        expect(pwd, equals(parent(cwd)));

        cd(cwd);
        expect(pwd, equals(cwd));
      });

      test("Push/Pop", () {
        String start = pwd;
        makeDir(pathTestDir, createParent: true);

        String expectedPath = absolute(pathTestDir);
        push(pathTestDir);
        expect(pwd, equals(expectedPath));

        pop();
        expect(pwd, equals(start));

        removeDir(TEST_ROOT, recursive: true);
      });

      test("Too many pops", () {
        expect(() => pop(), throwsA(TypeMatcher<PopException>()));
      });
    });
  } finally {
    cd(cwd);
  }
}
