import 'dart:io';

import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";
import 'package:path/path.dart' as p;

import '../test_settings.dart';

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

        TestDirectoryOverride dirOverride = TestDirectoryOverride();
        IOOverrides.runZoned(() {
          createDir("cd_test");
          cd("cd_test");
          t.expect(pwd, t.equals(absolute(join(testdir, "cd_test"))));
          cd("..");
          t.expect(pwd, t.equals(absolute(cwd)));

          cd(cwd);
          t.expect(pwd, t.equals(cwd));
        },
            createDirectory: (path) => dirOverride.makeDir(path),
            setCurrentDirectory: (path) =>
                dirOverride.current = TestDirectory(path),
            getCurrentDirectory: () => dirOverride.current);
      });

      t.test("Push/Pop", () {
        TestDirectoryOverride dirOverride = TestDirectoryOverride();
        IOOverrides.runZoned(() {
          String start = pwd;
          createDir(pathTestDir, createParent: true);

          String expectedPath = absolute(pathTestDir);
          push(pathTestDir);
          t.expect(pwd, t.equals(expectedPath));

          pop();
          t.expect(pwd, t.equals(start));

          deleteDir(pathTestDir, recursive: true);
        },
            createDirectory: (path) => dirOverride.makeDir(path),
            setCurrentDirectory: (path) =>
                dirOverride.current = TestDirectory(path),
            getCurrentDirectory: () => dirOverride.current);
      });

      t.test("Too many pops", () {
        t.expect(() => pop(), t.throwsA(t.TypeMatcher<PopException>()));
      });
    }, skip: true);
  } finally {
    cd(cwd);
  }
}

class TestDirectoryOverride {
  Directory _current = TestDirectory(absolute(TEST_ROOT));

  Set<String> paths = Set();
  TestDirectoryOverride();

  Directory get current => _current;

  set current(Directory current) => _current = current;

  Directory makeDir(String path) {
    paths.add(path);

    return TestDirectory(path);
  }
}

class TestDirectory implements Directory {
  String _path;

  TestDirectory(this._path);

  @override
  Directory get absolute => TestDirectory(p.absolute(_path));

  @override
  Future<Directory> create({bool recursive = false}) {
    // TODO: implement create
    return null;
  }

  @override
  void createSync({bool recursive = false}) {
    // TODO: implement createSync
  }

  @override
  Future<Directory> createTemp([String prefix]) {
    // TODO: implement createTemp
    return null;
  }

  @override
  Directory createTempSync([String prefix]) {
    // TODO: implement createTempSync
    return null;
  }

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) {
    // TODO: implement delete
    return null;
  }

  @override
  void deleteSync({bool recursive = false}) {
    // TODO: implement deleteSync
  }

  @override
  Future<bool> exists() {
    // TODO: implement exists
    return null;
  }

  @override
  bool existsSync() {
    // TODO: implement existsSync
    return null;
  }

  @override
  // TODO: implement isAbsolute
  bool get isAbsolute => null;

  @override
  Stream<FileSystemEntity> list(
      {bool recursive = false, bool followLinks = true}) {
    // TODO: implement list
    return null;
  }

  @override
  List<FileSystemEntity> listSync(
      {bool recursive = false, bool followLinks = true}) {
    // TODO: implement listSync
    return null;
  }

  @override
  // TODO: implement parent
  Directory get parent => null;

  @override
  // TODO: implement path
  String get path => null;

  @override
  Future<Directory> rename(String newPath) {
    // TODO: implement rename
    return null;
  }

  @override
  Directory renameSync(String newPath) {
    // TODO: implement renameSync
    return null;
  }

  @override
  Future<String> resolveSymbolicLinks() {
    // TODO: implement resolveSymbolicLinks
    return null;
  }

  @override
  String resolveSymbolicLinksSync() {
    // TODO: implement resolveSymbolicLinksSync
    return null;
  }

  @override
  Future<FileStat> stat() {
    // TODO: implement stat
    return null;
  }

  @override
  FileStat statSync() {
    // TODO: implement statSync
    return null;
  }

  @override
  // TODO: implement uri
  Uri get uri => null;

  @override
  Stream<FileSystemEvent> watch(
      {int events = FileSystemEvent.all, bool recursive = false}) {
    // TODO: implement watch
    return null;
  }
}
