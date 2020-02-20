import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/script/entry_point.dart';
import 'package:dshell/src/script/script.dart';
import 'package:dshell/src/script/virtual_project.dart';
import 'package:dshell/src/util/with_lock.dart';
import 'package:uuid/uuid.dart';

class TestFileSystem {
  String uniquePath;
  String top;
  String thidden;
  String middle;
  String bottom;
  String hidden;

  static const String _TEST_ROOT = '/tmp/dshell';
  static const String TEST_LINES_FILE = 'lines.txt';

  String home;

  /// The location of scripts used for testing.
  String testScriptPath;

  TestFileSystem() {
    uniquePath = Uuid().v4();

    testScriptPath = truepath(root, 'scripts');
  }

  String tempFile({String suffix}) => FileSync.tempFile(suffix: suffix);

  void withinZone(
    void Function(TestFileSystem fs) function, {
    bool preserveTestFileSystem = false,
    bool cleanInstall = false,
  }) {
    Lock(lockSuffix: 'test_file_system.lock').withLock(() {
      var home = HOME;
      try {
        setEnv('HOME', root);

        Settings().setVerbose(true);

        buildTestFileSystem();

        if (cleanInstall || !Settings().isInstalled) {
          install_dshell();
        }
        function(this);

        if (preserveTestFileSystem) {
          print('preserving TestFileSystem $root');
        } else {
          deleteTestFileSystem();
        }
      } finally {
        setEnv('HOME', home);
      }
    });
  }

  static TestFileSystem setup() {
    print('PWD $pwd');

    var paths = TestFileSystem();

    return paths;
  }

  String get unitTestWorkingDir {
    if (!exists(root)) {
      createDir(root, recursive: true);
    }
    return Directory(root).createTempSync().path;
  }

  String runtimePath(String scriptName) {
    var project = VirtualProject.create(
        Settings().dshellCachePath, Script.fromFile(scriptName));
    return project.runtimePath;
  }

  void buildTestFileSystem() {
    if (!exists(HOME)) {
      createDir(HOME, recursive: true);
    }
    top = join(root, 'top');
    thidden = join(top, '.hidden');
    middle = join(top, 'middle');
    bottom = join(middle, 'bottom');
    hidden = join(middle, '.hidden');

    // Create some the test dirs.
    if (!exists(thidden)) {
      createDir(thidden, recursive: true);
    }

    // Create some the test dirs.
    if (!exists(bottom)) {
      createDir(bottom, recursive: true);
    }

    // Create some the test dirs.
    if (!exists(hidden)) {
      createDir(hidden, recursive: true);
    }

    // Create test files

    touch(join(thidden, 'fred.txt'), create: true);

    touch(join(top, 'one.txt'), create: true);
    touch(join(top, 'two.txt'), create: true);
    touch(join(top, 'one.jpg'), create: true);
    touch(join(top, '.two.txt'), create: true);

    touch(join(middle, 'three.txt'), create: true);
    touch(join(middle, 'four.txt'), create: true);
    touch(join(middle, 'two.jpg'), create: true);
    touch(join(middle, '.four.txt'), create: true);

    touch(join(bottom, 'five.txt'), create: true);
    touch(join(bottom, 'six.txt'), create: true);
    touch(join(bottom, 'three.jpg'), create: true);

    touch(join(hidden, 'seven.txt'), create: true);
    touch(join(hidden, '.seven.txt'), create: true);
  }

  void deleteTestFileSystem() {
    if (exists(HOME)) {
      print('Deleting $HOME');
      deleteDir(HOME, recursive: true);
    }
    if (exists(root)) {
      print('Deleting $root');
      deleteDir(root, recursive: true);
    }
  }

  String get root => join(TestFileSystem._TEST_ROOT, uniquePath);

  void install_dshell() {
    EntryPoint().process(['install']);
  }
}
