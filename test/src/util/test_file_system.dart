@Timeout(Duration(seconds: 600))
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/functions/env.dart';
import 'package:dshell/src/pubspec/global_dependencies.dart';
import 'package:dshell/src/util/dshell_paths.dart';
import 'package:path/path.dart';
import 'package:dshell/src/script/entry_point.dart';
import 'package:dshell/src/script/script.dart';
import 'package:dshell/src/script/virtual_project.dart';
import 'package:dshell/src/util/named_lock.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:dshell/src/util/pub_cache.dart';

class TestFileSystem {
  String uniquePath;
  String top;
  String thidden;
  String middle;
  String bottom;
  String hidden;

  static String _testRoot;

  /// directory under .dshell which we used to store compiled
  /// tests scripts that we need to add to the TestFileSystems
  /// path.
  static const String _testBin = 'test_bin';
  static const String testLinesFile = 'lines.txt';

  String home;

  String get root => join(TestFileSystem._testRoot, uniquePath);

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
    _testRoot = join(rootPath, 'tmp', 'dshell');
    uniquePath = Uuid().v4();

    var isolateID = Service.getIsolateID(Isolate.current);
    print(red('Creating TestFileSystem $root for isolate $isolateID'));

    testScriptPath = truepath(root, 'scripts');
  }

  String tempFile({String suffix}) => FileSync.tempFile(suffix: suffix);

  void withinZone(void Function(TestFileSystem fs) callback) {
    try {
      NamedLock(name: 'test_file_system.lock').withLock(() {
        Settings.reset();
        Env.reset();
        PubCache.reset();
        // print('PATH: $PATH');
        // print(which(DartSdk.pubExeName).firstLine);
        var home = HOME;
        var path = env('PATH');
        try {
          setEnv('HOME', root);

          rebuildPath();

          var isolateID = Service.getIsolateID(Isolate.current);
          print(green('Using TestFileSystem $root for Isolate: $isolateID'));
          print('Reset dshellPath: ${Settings().dshellPath}');

          initFS(home);

          callback(this);
        }
        // ignore: avoid_catches_without_on_clauses
        catch (e, st) {
          Settings().verbose(e.toString());
          st.toString();
          rethrow;
        } finally {
          setEnv('HOME', home);
          setEnv('PATH', path);
        }
      });
    } on DShellException catch (e) {
      print(e.toString());
      e.printStackTrace();
      rethrow;
    }
  }

  void initFS(String originalHome) {
    if (!initialised) {
      initialised = true;
      copyPubCache(originalHome, HOME);
      buildTestFileSystem();
      installDshell();
      installCrossPlatformTestScripts(originalHome);
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
    return project.runtimeProjectPath;
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

  void installDshell() {
    /// run pub get and only display errors.
    '${DartSdk.pubExeName} global activate --source path $pwd'.start(
        progress: Progress((line) => null, stderr: (line) => print(line)));

    EntryPoint().process(['install', '--nodart', '--quiet']);

    /// rewrite dependencies.yaml so that the dshell path points
    /// to the dev build directory
    var dependencyFile =
        join(Settings().dshellPath, GlobalDependencies.filename);
    var lines = read(dependencyFile).toList();

    var newContent = <String>[];

    for (var line in lines) {
      if (line.trim().startsWith('dshell')) {
        newContent.add('  dshell:');
        newContent.add('    path: $pwd');
      } else {
        newContent.add(line);
      }
    }

    var backup = '$dependencyFile.bak';
    if (exists(backup)) delete(backup);
    move(dependencyFile, backup);

    dependencyFile.write(newContent.join('\n'));
  }

  void rebuildPath() {
    var newPath = <String>[];

    // remove .pub-cache and .dshell... and replace with the test FS ones

    if (PATH == null || PATH.isEmpty) {
      print(red('PATH is empty'));
    }
    for (var path in PATH) {
      if (path.contains(PubCache().path) || path.contains('.dshell')) {
        continue;
      }

      newPath.add(path);
    }

    newPath.add('${join(root, PubCache().binPath)}');
    newPath.add('${join(root, '.dshell', 'bin')}');

    setEnv('PATH', newPath.join(Env().pathDelimiter));
  }

  void copyPubCache(String originalHome, String newHome) {
    print('Copying pub cache into TestFileSystem');
    var list = find(
      '*',
      root: join(originalHome, PubCache().cacheDir),
      recursive: true,
    ).toList();

    var verbose = Settings().isVerbose;

    Settings().setVerbose(enabled: false);

    for (var file in list) {
      var target = join(newHome, relative(file, from: originalHome));

      if (!exists(dirname(target))) createDir(dirname(target), recursive: true);

      copy(file, target);
    }

    Settings().setVerbose(enabled: verbose);
  }

  void installCrossPlatformTestScripts(String originalHome) {
    var required = ['head', 'tail', 'ls', 'touch'];

    var testbinPath = join(originalHome, '.dshell', _testBin);

    if (!exists(testbinPath)) {
      createDir(testbinPath, recursive: true);
    }

    for (var command in required) {
      if (exists(join(testbinPath, command))) {
        // copy the existing command into the testzones .dshell/bin path
        copy(join(testbinPath, command),
            join(Settings().dshellBinPath, command));
      } else {
        /// compile and install the command
        '${DShellPaths().dshellName} compile -i test/test_scripts/$command.dart'
            .run;
        // copy it back to the dshell testbin so the next unit
        // test doesn't have to compile it.
        copy(join(Settings().dshellBinPath, command),
            join(testbinPath, command));
      }
    }
  }
}

class TestFileSystemException extends DShellException {
  TestFileSystemException(String message) : super(message);
}
