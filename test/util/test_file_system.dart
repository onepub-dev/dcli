@Timeout(Duration(seconds: 600))
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/functions/env.dart';
import 'package:path/path.dart';
import 'package:dshell/src/script/entry_point.dart';
import 'package:dshell/src/script/script.dart';
import 'package:dshell/src/script/virtual_project.dart';
import 'package:dshell/src/util/with_lock.dart';
import 'package:test/test.dart';
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

  String get root => join(TestFileSystem._TEST_ROOT, uniquePath);

  bool initialised = false;

  /// The location of scripts used for testing.
  String testScriptPath;

  static TestFileSystem common;

  /// The TestFileSystem allows you to run
  /// unit tests in a 'virtualised' filesystem.
  ///
  /// The 'virtualised' filesystem only provides
  /// very weak containment and you need to follow
  /// a couple of rules or you tests will write over
  /// the rest of your file system.
  ///
  /// The virtualised file system is created by altering the
  /// 'HOME' environment variable and by providing a
  /// 'root' path [TestFileSystem.root]
  /// You MUST prefix all of your paths of either [root] or
  /// [HOME] to ensure that you code runs within the 'virtuallised'
  /// files system.
  ///
  /// Each virtualised file system has its own copy of dshell installed.
  ///
  ///
  /// Any test which is non-desctructive
  /// can use a common TestFileSystem by setting [useCommonPath] to
  /// [true] which is the default.
  ///
  /// Using a common file system greatly speeds
  /// up testing as we don't need to install
  /// a unique copy of dshell for each test.
  ///
  /// Set [useCommonPath] to [false] to run your own
  /// copy of dshell. This should be used if you are testing
  /// dshell's install.
  ///
  factory TestFileSystem({bool useCommonPath = true}) {
    TestFileSystem use;
    if (useCommonPath) {
      common ??= TestFileSystem._internal();
      use = common;
    } else {
      use = TestFileSystem._internal();
    }

    return use;
  }

  TestFileSystem._internal() {
    uniquePath = Uuid().v4();

    var isolateID = Service.getIsolateID(Isolate.current);
    print(red('Creating TestFileSystem $root for isolate $isolateID'));

    testScriptPath = truepath(root, 'scripts');
  }

  String tempFile({String suffix}) => FileSync.tempFile(suffix: suffix);

  void withinZone(void Function(TestFileSystem fs) callback) {
    NamedLock(name: 'test_file_system.lock').withLock(() {
      Settings.reset();
      Env.reset();
      var home = HOME;
      var path = env('PATH');
      try {
        setEnv('HOME', root);

        rebuildPath();

        var isolateID = Service.getIsolateID(Isolate.current);
        print(green(
            'Using TestFileSystem $root for Isolateexecutable: $isolateID'));
        print('Reset dshellPath: ${Settings().dshellPath}');

        initFS(home);

        callback(this);
      } catch (e) {
        Settings().verbose(e.toString());
        rethrow;
      } finally {
        setEnv('HOME', home);
        setEnv('PATH', path);
      }
    });
  }

  void initFS(String originalHome) {
    if (!initialised) {
      initialised = true;
      copyPubCache(originalHome, HOME);
      buildTestFileSystem();
      install_dshell();
    }
  }

  static TestFileSystem setup() {
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
    var project = VirtualProject.load(Script.fromFile(scriptName));
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

    touch(join(top, 'fred.jpg'), create: true);
    touch(join(top, 'fred.png'), create: true);
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
      Settings().verbose('Deleting $HOME');
      deleteDir(HOME, recursive: true);
    }
    if (exists(root)) {
      Settings().verbose('Deleting $root');
      deleteDir(root, recursive: true);
    }
  }

  void install_dshell() {
    'pub global activate --source path $pwd'.run;
    EntryPoint().process(['install']);
  }

  void rebuildPath() {
    var newPath = <String>[];

    // remove .pub-cache and .dshell... and replace with the test FS ones

    if (PATH == null || PATH.isEmpty) {
      print(red('PATH is empty'));
    }
    for (var path in PATH) {
      if (path.contains('.pub-cache') || path.contains('.dshell')) {
        continue;
      }

      newPath.add(path);
    }

    newPath.add('${join(root, ".pub-cache", "bin")}');
    newPath.add('${join(root, '.dshell', 'bin')}');

    setEnv('PATH', newPath.join(':'));
  }

  void copyPubCache(String originalHome, String newHome) {
    print('Copying .pub-cache into TestFileSystem');
    var list = find(
      '*',
      root: join(originalHome, '.pub-cache'),
      recursive: true,
    ).toList();

    var verbose = Settings().isVerbose;

    Settings().setVerbose(false);

    for (var file in list) {
      var target = join(newHome, relative(file, from: originalHome));

      if (!exists(dirname(target))) createDir(dirname(target), recursive: true);

      copy(file, target);
    }

    Settings().setVerbose(verbose);
  }
}
