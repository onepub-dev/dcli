import 'dart:io';

import 'package:dshell/util/log.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";
import 'package:path/path.dart' as p;

import '../test_settings.dart';
import '../util/directory_override.dart';

void main() {
  Settings().debug_on = true;
  String cwd = pwd;
  String TEST_DIR = "path_test";

  // can't be run in parallel to other tests as it chana
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

        final MemoryFileSystem fs = MemoryFileSystem();

        // fs.file(path)

        TestZone().run(() {
          // var lfs = LocalFileSystem();
          // lfs.systemTempDirectory.createTempSync("fred");
          // lfs.path;
          // FileSystem();
          // Directory().createTempSync()
          createDir("cd_test", createParent: true);
          cd("cd_test");
          t.expect(pwd, t.equals(absolute(join(testdir, "cd_test"))));
          cd("..");
          t.expect(pwd, t.equals(absolute(cwd)));

          cd(cwd);
          t.expect(pwd, t.equals(cwd));
        });
      });

      t.test("Push/Pop", () {
        TestZone().run(() {
          String start = pwd;
          createDir(pathTestDir, createParent: true);

          String expectedPath = absolute(pathTestDir);
          push(pathTestDir);
          t.expect(pwd, t.equals(expectedPath));

          pop();
          t.expect(pwd, t.equals(start));

          deleteDir(pathTestDir, recursive: true);
        });
      });

      t.test("Too many pops", () {
        t.expect(() => pop(), t.throwsA(t.TypeMatcher<PopException>()));
      });
    });
  } finally {
    cd(cwd);
  }
}
