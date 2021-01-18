@Timeout(Duration(seconds: 600))
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/functions/env.dart';
import 'package:dcli/src/pubspec/dependency.dart';
import 'package:dcli/src/util/stack_trace_impl.dart';
import 'package:path/path.dart';
import 'package:dcli/src/script/entry_point.dart';
import 'package:dcli/src/util/named_lock.dart';
import 'package:pubspec/pubspec.dart' as ps;
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

  String get fsRoot => join(TestFileSystem._testRoot, uniquePath);

  bool initialised = false;

  bool installDcli;

  /// The location of any temp scripts
  /// that need to be created during testing.
  String tmpScriptPath;

  /// The location of the test_script directory
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
  /// 'root' path [TestFileSystem.fsRoot]
  /// You MUST prefix all of your paths of either [fsRoot] or
  /// [HOME] to ensure that you code runs within the 'virtuallised'
  /// files system.
  ///
  /// Each virtualised file system has its own copy of dcli installed.
  ///
  ///
  /// Any test which is non-desctructive
  /// can use a common TestFileSystem by setting [useCommonPath] to
  /// true which is the default.
  ///
  /// Using a common file system greatly speeds
  /// up testing as we don't need to install
  /// a unique copy of dcli for each test.
  ///
  /// Set [useCommonPath] to false to run your own
  /// copy of dcli. This should be used if you are testing
  /// dcli's install.
  ///
  factory TestFileSystem({bool useCommonPath = true, bool installDcli = true}) {
    TestFileSystem use;
    if (useCommonPath) {
      print(orange('Re-using common TestFileSystem'));
      common ??= TestFileSystem._internal(installDcli: installDcli);
      use = common;
    } else {
      use = TestFileSystem._internal(installDcli: installDcli);
    }

    return use;
  }

  TestFileSystem._internal({this.installDcli}) {
    _testRoot = join(rootPath, 'tmp', 'dcli');
    uniquePath = Uuid().v4();

    final isolateID = Service.getIsolateID(Isolate.current);
    print(
        red('${'+' * 20}${'Creating TestFileSystem $fsRoot for isolate $isolateID'}') +
            '+' * 20);

    tmpScriptPath = truepath(fsRoot, 'scripts');
    testScriptPath = truepath(fsRoot, 'test_script');
  }

  String tempFile({String suffix}) => FileSync.tempFile(suffix: suffix);

  String originalPubCache;

  void withinZone(
    void Function(TestFileSystem fs) callback,
  ) {
    final stack = StackTraceImpl(skipFrames: 1);

    try {
      NamedLock(name: 'test_file_system.lock').withLock(() {
        final frame = stack.frames[0];

        print(red(
            '${'*' * 40} Starting test ${frame.sourceFile}:${frame.lineNo} ${'*' * 80}'));
        Settings.reset();
        Env.reset();
        PubCache.reset();
        originalPubCache = PubCache().pathTo;
        // print('PATH: $PATH');
        final originalHome = HOME;
        final path = env['PATH'];
        try {
          env['HOME'] = fsRoot;
          home = fsRoot;

          /// Force PubCache path to point at the new file system.
          PubCache().pathTo = join(fsRoot, PubCache().cacheDir);

          rebuildPath();

          final isolateID = Service.getIsolateID(Isolate.current);
          print(green('Using TestFileSystem $fsRoot for Isolate: $isolateID'));
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
          print(green(
              '${'-' * 40} Ending test ${frame.sourceFile}:${frame.lineNo} ${'-' * 80}'));
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

      /// If we copy pub-cache we also need to
      /// copy the testscripts as when the .dart_tools
      /// is created it includes absolute paths to the pub-cache.
      /// If we are creating/destroying pub-caches and sharing
      /// the tests scripts the paths to pub-cache keep getting
      /// broken.
      copyPubCache(originalHome, HOME);
      copyTestScripts();
      if (installDcli) {
        installDCli();
      }
      buildTestFileSystem();

      installCrossPlatformTestScripts(originalHome);
    }
  }

  // ignore: prefer_constructors_over_static_methods
  static TestFileSystem setup() {
    final paths = TestFileSystem();

    return paths;
  }

  String get unitTestWorkingDir {
    if (!exists(fsRoot)) {
      createDir(fsRoot, recursive: true);
    }
    return Directory(fsRoot).createTempSync().path;
  }

  String runtimePath(String scriptName) {
    final script = Script.fromFile(scriptName);
    return script.pathToProjectRoot;
  }

  void buildTestFileSystem() {
    if (!exists(HOME)) {
      createDir(HOME, recursive: true);
    }

    top = join(fsRoot, 'top');
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
      deleteDir(HOME);
    }
    if (exists(fsRoot)) {
      Settings().verbose('Deleting $fsRoot');
      deleteDir(fsRoot);
    }
  }

  void installDCli() {
    /// run pub get and only display errors.
    '${DartSdk.dartExeName} pub global activate --source path $pwd'.start(
        progress: Progress((line) => null, stderr: (line) => print(line)));

    EntryPoint().process(['install', '--nodart', '--quiet', '--noprivileges']);
  }

  void rebuildPath() {
    final newPath = <String>[];

    // remove .pub-cache and .dcli... and replace with the test FS ones

    if (PATH == null || PATH.isEmpty) {
      print(red('PATH is empty'));
    }
    for (final path in PATH) {
      if (isWithin(originalPubCache, path) || path.contains('.dcli')) {
        continue;
      }

      newPath.add(path);
    }

    newPath.add(PubCache().pathToBin);
    newPath.add(join(fsRoot, '.dcli', 'bin'));

    env['PATH'] = newPath.join(Env().delimiterForPATH);
  }

  void copyPubCache(String originalHome, String newHome) {
    print('Copying pub cache into TestFileSystem... ');

    final verbose = Settings().isVerbose;

    Settings().setVerbose(enabled: false);

    /// tell the world where to find the new pubache.
    //  PubCache().pathTo = join(newHome, PubCache().cacheDir);

    if (!exists(PubCache().pathTo)) {
      createDir(PubCache().pathTo, recursive: true);
    }

    copyTree(originalPubCache, PubCache().pathTo);

    print(
        'Reset ${PubCache.envVarPubCache} to ${env[PubCache.envVarPubCache]}');

    Settings().setVerbose(enabled: verbose);
  }

  //
  void copyTestScripts() {
    print('Copying test_script into TestFileSystem... ');

    final verbose = Settings().isVerbose;

    Settings().setVerbose(enabled: false);

    if (!exists(testScriptPath)) {
      createDir(testScriptPath, recursive: true);
    }

    copyTree(join(Script.current.pathToProjectRoot, 'test', 'test_script'),
        testScriptPath);

    _patchRelativeDependenciesAndWarmup(testScriptPath);
    DartProject.fromPath(join(testScriptPath, 'general')).warmup();

    Settings().setVerbose(enabled: verbose);
  }

  /// we need to update any pubspec.yaml files that have a relative
  /// dependency to dcli after we move them to the test file system.
  void _patchRelativeDependenciesAndWarmup(String testScriptPath) {
    find('pubspec.yaml', root: testScriptPath).forEach((pathToPubspec) {
      final pubspec = PubSpec.fromFile(pathToPubspec);
      final dependency = pubspec.dependencies['dcli'];

      final dcliProject = DartProject.fromPath('.');

      if (dependency.reference is ps.PathReference) {
        final pathDependency = dependency.reference as ps.PathReference;

        final dir = relative(dirname(pathToPubspec), from: fsRoot);
        final absolutePathToDcli = truepath(
            dcliProject.pathToProjectRoot, 'test', dir, pathDependency.path);

        final newPath = PubSpec.createPathReference(absolutePathToDcli);

        final newMap = Map<String, Dependency>.from(pubspec.dependencies);
        newMap['dcli'] = Dependency('dcli', newPath);
        pubspec.dependencies = newMap;
        pubspec.saveToFile(pathToPubspec);
      }

      DartProject.fromPath(dirname(pathToPubspec)).warmup();
    });
  }

  void installCrossPlatformTestScripts(String originalHome) {
    final required = ['head', 'tail', 'ls', 'touch'];

    final testbinPath = join(originalHome, '.dcli', _testBin);

    if (!exists(testbinPath)) {
      createDir(testbinPath, recursive: true);
    }

    // may not exists on the first pass through.
    if (!exists(Settings().pathToDCliBin)) {
      createDir(Settings().pathToDCliBin, recursive: true);
    }

    for (final command in required) {
      if (exists(join(testbinPath, command))) {
        // copy the existing command into the testzones .dcli/bin path
        copy(join(testbinPath, command),
            join(Settings().pathToDCliBin, command));
      } else {
        /// compile and install the command
        final script =
            Script.fromFile('test/test_script/general/bin/$command.dart');
        script.compile(install: true);

        // copy it back to the dcli testbin so the next unit
        // test doesn't have to compile it.
        /// not necessary as we compile directly into the test bin.
        // copy(script.pathToExe, join(testbinPath, script.exeName));
      }
    }
  }
}

class TestFileSystemException extends DCliException {
  TestFileSystemException(String message) : super(message);
}
