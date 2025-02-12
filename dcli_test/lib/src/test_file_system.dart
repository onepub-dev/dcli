@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../dcli_test.dart';
import 'test_directory_tree.dart';

class TestFileSystem {
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
  /// You MUST prefix all of your paths with either [fsRoot] or
  /// [HOME] to ensure that you code runs within the 'virtuallised'
  /// files system.
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
  factory TestFileSystem(
      {bool useCommonPath = true, bool includeProjectTemplates = false}) {
    TestFileSystem? use;
    if (useCommonPath) {
      print(blue('Re-using common TestFileSystem'));

      use = common;
    } else {
      use = TestFileSystem._internal(
          includeProjectTemplates: includeProjectTemplates);
    }

    return use;
  }

  TestFileSystem._internal({required bool includeProjectTemplates})
      : originalHome = HOME {
    _testRoot = join(rootPath, 'tmp', 'dcli');
    uniquePath = const Uuid().v4();

    final isolateID = Service.getIsolateId(Isolate.current);
    print(
      blue(
            '${'+' * 20}'
            '${'Creating TestFileSystem $fsRoot for isolate $isolateID'}',
          ) +
          '+' * 20,
    );

    tmpScriptPath = truepath(fsRoot, 'scripts');
    testScriptPath = truepath(fsRoot, 'test_script');

    if (includeProjectTemplates) {
      copyProjectTemplates();
    }
  }

  /// The user actual HOME directory.
  final String originalHome;

  late String uniquePath;

  static late String _testRoot;

  TestDirectoryTree? testDirectoryTree;

  /// directory under .dcli which we used to store compiled
  /// tests scripts that we need to add to the TestFileSystems
  /// path.
  static const String testLinesFile = 'lines.txt';

  String? home;

  String get fsRoot => join(TestFileSystem._testRoot, uniquePath);

  bool initialised = false;

  bool dcliActivated = false;

  /// The location of any temp scripts
  /// that need to be created during testing.
  late String tmpScriptPath;

  /// The location of the test_script directory
  late String testScriptPath;

  static TestFileSystem common =
      TestFileSystem._internal(includeProjectTemplates: true);

  String tempFile({String? suffix}) => createTempFilename(suffix: suffix);

  String? originalPubCache;

  /// Run the passed callback [action] within the scope
  /// of the [TestFileSystem].
  Future<void> withinZone(
    Future<void> Function(TestFileSystem fs) action,
  ) async {
    final stack = Trace.current(1);

    await withTestScope((testDir) async {
      await _runUnderLock(stack, action);
    }, pathToTestDir: fsRoot);
  }

  Future<void> _runUnderLock(
    Trace stack,
    Future<void> Function(TestFileSystem fs) action,
  ) async {
    final frame = stack.frames[0];

    print(
      green(
        '${'*' * 40} Starting test '
        '${frame.library}:${frame.line} ${'*' * 80}',
      ),
    );

    try {
      env['HOME'] = fsRoot;
      home = fsRoot;

      final isolateID = Service.getIsolateId(Isolate.current);
      print(green('Using TestFileSystem $fsRoot for Isolate: $isolateID'));

      await initFS();

      if (!dcliActivated) {
        print(blue('Globally activating DCli into test file system'));
        await capture(() async {
          PubCache().globalActivateFromSource(
              join(DartProject.self.pathToProjectRoot, '..', 'dcli_sdk'));
        }, progress: Progress.printStdErr());
        dcliActivated = true;
      }

      await action(this);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e, st) {
      verbose(e.toString);
      st.toString();
      rethrow;
    } finally {
      print(
        green(
          '${'-' * 40} '
          'Ending test ${frame.library}:${frame.line} ${'-' * 80}',
        ),
      );
    }
  }

  Future<void> initFS() async {
    if (!initialised) {
      initialised = true;

      /// If we copy pub-cache we also need to
      /// copy the testscripts as when the .dart_tools
      /// is created it includes absolute paths to the pub-cache.
      /// If we are creating/destroying pub-caches and sharing
      /// the tests scripts the paths to pub-cache keep getting
      /// broken.
      // copyPubCache(originalHome, HOME);
      await copyTestScripts();
      testDirectoryTree = TestDirectoryTree(fsRoot);

      copyPubTokens();

      await installCrossPlatformTestScripts();
    }
  }

  /// Copy the pub.dev pub-tokens so that we can use onepub within
  /// the test file system.
  void copyPubTokens() {
    final pathToDartConfig = join('.config', 'dart');
    final originalDartConfig = join(originalHome, pathToDartConfig);
    final testFSDartConfig = join(HOME, pathToDartConfig);
    if (!exists(testFSDartConfig)) {
      createDir(testFSDartConfig, recursive: true);
    }
    copyTree(originalDartConfig, testFSDartConfig, overwrite: true);
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
    final script = DartScript.fromFile(scriptName);
    return script.pathToProjectRoot;
  }

  /// Used by third parties to build a populated and
  /// well know diretory tree for testing.
  static void buildDirectoryTree(String root,
      {bool includedEmptyDir = false}) {
    final top = join(root, 'top');
    final thidden = join(top, '.hidden');
    final middle = join(top, 'middle');
    final bottom = join(middle, 'bottom');
    final hidden = join(middle, '.hidden');

    if (includedEmptyDir) {
      final empty = join(root, 'empty');
      createDir(empty);
    }

    populateFileSystem(top, thidden, middle, bottom, hidden);
  }

  static void populateFileSystem(
    String top,
    String thidden,
    String middle,
    String bottom,
    String hidden,
  ) {
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
      verbose(() => 'Deleting $HOME');
      deleteDir(HOME);
    }
    if (exists(fsRoot)) {
      verbose(() => 'Deleting $fsRoot');
      deleteDir(fsRoot);
    }
  }

  void rebuildPath() {
    // remove .pub-cache and .dcli... and replace with the test FS ones

    if (PATH.isEmpty) {
      print(red('PATH is empty'));
    }
    for (final path in PATH) {
      if (isWithin(originalPubCache!, path) || path.contains('.dcli')) {
        continue;
      }

      Env().appendToPATH(path);
    }

    Env().appendToPATH(PubCache().pathToBin);
    Env().appendToPATH(join(fsRoot, '.dcli', 'bin'));
  }

  //
  Future<void> copyTestScripts() async {
    print('Copying test_script into TestFileSystem... ');

    final verbose = Settings().isVerbose;

    Settings().setVerbose(enabled: false);

    if (!exists(testScriptPath)) {
      createDir(testScriptPath, recursive: true);
    }

    copyTree(
      join(pathToPackageUnitTester, 'test', 'test_script'),
      testScriptPath,
    );

    Settings().setVerbose(enabled: verbose);
    await _patchRelativeDependenciesAndWarmup(testScriptPath);
  }

  /// we need to update any pubspec.yaml files that have a relative
  /// dependency to dcli after we move them to the test file system.
  Future<void> _patchRelativeDependenciesAndWarmup(
      String testScriptPath) async {
    final projects =
        find('pubspec.yaml', workingDirectory: testScriptPath).toList();

    for (final pathToPubspec in projects) {
      final dcliProject = DartProject.fromPath('.');

      final pathToDCliRoot = dirname(dcliProject.pathToProjectRoot);

      join(dirname(pathToPubspec), 'pubspec_overrides.yaml').write('''
dependency_overrides: 
  dcli: 
    path: ${join(pathToDCliRoot, 'dcli')}
  dcli_common: 
    path: ${join(pathToDCliRoot, 'dcli_common')}
  dcli_core: 
    path: ${join(pathToDCliRoot, 'dcli_core')}
  dcli_input: 
    path: ${join(pathToDCliRoot, 'dcli_input')}
  dcli_terminal: 
    path: ${join(pathToDCliRoot, 'dcli_terminal')}  
        ''');

      // ignore: discarded_futures
      // await capture(() async {
      await DartProject.fromPath(dirname(pathToPubspec)).warmup(upgrade: true);
      // }, progress: Progress.printStdErr());
    }
  }

  static String pathToTools = join(rootPath, 'tmp', 'dcli_tools');
  static String pathToToolPubspec = join(pathToTools, 'pubspec.yaml');

  /// We install the cross platform tools into a tool directory
  /// shared by all of the test file systems.
  /// Each time a new test file system is instantiated this method
  /// is called. We check if the tools are missing
  /// and build them if necessary.
  /// As these tools are quite static and the tool path is
  /// in /tmp (so deleted after every reboot) we only
  /// recompile the tools if they are missing.
  Future<void> installCrossPlatformTestScripts() async {
    if (!exists(pathToTools)) {
      createDir(pathToTools, recursive: true);
    }

    final tools = ['head', 'tail', 'ls', 'touch', 'run_child'];

    // may not exists on the first pass through.
    if (!exists(pathToTools)) {
      createDir(pathToTools, recursive: true);
    }

    final pathToToolProject =
        join(pathToPackageUnitTester, 'test', 'test_script', 'general');

    final toolProject = DartProject.fromPath(pathToToolProject);

    await capture(() async {
      if (!toolProject.isReadyToRun) {
        await toolProject.warmup();
      }
    }, progress: Progress.printStdErr());

    print(blue('compiling cross platform tools'));
    await NamedLock(name: 'compile').withLockAsync(() async {
      for (final command in tools) {
        final pathToTool = join(pathToTools, command);
        final pathToToolSource =
            join(pathToToolProject, 'bin', '$command.dart');
        if (_compileRequired(pathToTool, pathToToolSource)) {
          final script = DartScript.fromFile(pathToToolSource);
          if (!exists(join(pathToTools, '$command.dart'))) {
            /// compile and install the command into the tool path
            script.compile();
            copy(script.pathToExe, pathToTools, overwrite: true);
          }
        }
      }
    });
  }

  bool _compileRequired(String pathToTool, String pathToToolSource) {
    if (!exists(pathToTool)) {
      return true;
    }

    /// If the source has been modified since the tool was compiled
    /// This isn't a perfect test as the tool may rely on some other
    /// library that has been modified.
    return stat(pathToTool).modified.isBefore(stat(pathToToolSource).modified);
  }

  bool isDCliRunningFromSource() =>
      PubCache().isGloballyActivatedFromSource('dcli_sdk');

  /// Copies the dcli project templates
  void copyProjectTemplates() {
    final templateProjectPath =
        join(fsRoot, '.dcli', Settings.templateDir, 'project');

    createDir(templateProjectPath, recursive: true);

    copyTree(join(originalHome, '.dcli', Settings.templateDir, 'project'),
        templateProjectPath);
  }
}

class TestFileSystemException extends DCliException {
  TestFileSystemException(super.message);
}
