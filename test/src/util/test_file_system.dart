@Timeout(Duration(seconds: 600))
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/functions/env.dart';
import 'package:dcli/src/pubspec/global_dependencies.dart';
import 'package:dcli/src/util/dcli_paths.dart';
import 'package:path/path.dart';
import 'package:dcli/src/script/entry_point.dart';
import 'package:dcli/src/script/script.dart';
import 'package:dcli/src/script/virtual_project.dart';
import 'package:dcli/src/util/named_lock.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:dcli/src/util/pub_cache.dart';

class TestFileSystem {
  String uniquePath;
  String top;
  String thidden;
  String middle;
  String bottom;
  String hidden;

  static String _testRoot;

  /// directory under .dcli which we used to store compiled
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
  /// Each virtualised file system has its own copy of dcli installed.
  ///
  ///
  /// Any test which is non-desctructive
  /// can use a common TestFileSystem by setting [useCommonPath] to
  /// [true] which is the default.
  ///
  /// Using a common file system greatly speeds
  /// up testing as we don't need to install
  /// a unique copy of dcli for each test.
  ///
  /// Set [useCommonPath] to [false] to run your own
  /// copy of dcli. This should be used if you are testing
  /// dcli's install.
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
    _testRoot = join(rootPath, 'tmp', 'dcli');
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
        var originalHome = HOME;
        var path = env['PATH'];
        try {
          env['HOME'] = root;
          home = root;

          rebuildPath();

          var isolateID = Service.getIsolateID(Isolate.current);
          print(green('Using TestFileSystem $root for Isolate: $isolateID'));
          print('Reset dcliPath: ${Settings().pathToDCli}');

          initFS(originalHome);

          callback(this);
        }
        // ignore: avoid_catches_without_on_clauses
        catch (e, st) {
          Settings().verbose(e.toString());
          st.toString();
          rethrow;
        } finally {
          env['HOME'] = originalHome;
          env['PATH'] = path;
        }
      });
    } on DCliException catch (e) {
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
      installDCli();
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
    return project.pathToRuntimeProject;
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

  void installDCli() {
    /// run pub get and only display errors.
    '${DartSdk.pubExeName} global activate --source path $pwd'
        .start(progress: Progress((line) => null, stderr: (line) => print(line)));

    EntryPoint().process(['install', '--nodart', '--quiet']);

    /// rewrite dependencies.yaml so that the dcli path points
    /// to the dev build directory
    var dependencyFile = join(Settings().pathToDCli, GlobalDependencies.filename);
    var lines = read(dependencyFile).toList();

    var newContent = <String>[];

    for (var line in lines) {
      if (line.trim().startsWith('dcli')) {
        newContent.add('  dcli:');
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

    // remove .pub-cache and .dcli... and replace with the test FS ones

    if (PATH == null || PATH.isEmpty) {
      print(red('PATH is empty'));
    }
    for (var path in PATH) {
      if (path.contains(PubCache().pathTo) || path.contains('.dcli')) {
        continue;
      }

      newPath.add(path);
    }

    newPath.add('${join(root, PubCache().pathToBin)}');
    newPath.add('${join(root, '.dcli', 'bin')}');

    env['PATH'] = newPath.join(Env().delimiterForPATH);
  }

  void copyPubCache(String originalHome, String newHome) {
    print('Copying pub cache into TestFileSystem... ');
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

    var testbinPath = join(originalHome, '.dcli', _testBin);

    if (!exists(testbinPath)) {
      createDir(testbinPath, recursive: true);
    }

    // may not exists on the first pass through.
    if (!exists(Settings().pathToDCliBin)) {
      createDir(Settings().pathToDCliBin, recursive: true);
    }

    for (var command in required) {
      if (exists(join(testbinPath, command))) {
        // copy the existing command into the testzones .dcli/bin path
        copy(join(testbinPath, command), join(Settings().pathToDCliBin, command));
      } else {
        /// compile and install the command
        '${DCliPaths().dcliName} compile -i test/test_scripts/general/bin/$command.dart'.run;
        // copy it back to the dcli testbin so the next unit
        // test doesn't have to compile it.
        copy(join(Settings().pathToDCliBin, command), join(testbinPath, command));
      }
    }
  }
}

class TestFileSystemException extends DCliException {
  TestFileSystemException(String message) : super(message);
}
