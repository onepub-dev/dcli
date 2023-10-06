/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:pubspec_manager/pubspec_manager.dart';
import 'package:stack_trace/stack_trace.dart';

import '../../dcli.dart';
import 'dart_script_creator.dart';
import 'runner.dart';

/// Used to manage a DCli script.
///
/// We expose [DartScript] as it permits some self discovery
/// of the dart script you are currently running.
///
///
class DartScript {
  factory DartScript.createScript(
      {required DartProject project,
      required String scriptName,
      required String templateName}) {
    scriptCreator(
        project: project, scriptName: scriptName, templateName: templateName);

    return DartScript.fromFile(join(project.pathToProjectRoot, scriptName));
  }

  /// Path to the currently runnng script
  // static String? __pathToCurrentScript;

  DartScript._self() {
    final script = Platform.script;

    String pathToScript;

    if (inUnitTest) {
      pathToScript = _unitTestPath ?? '';
    } else if (script.isScheme('file')) {
      pathToScript = Platform.script.toFilePath();

      pathToScript = stripDartVersionSuffix(pathToScript);

      if (_isCompiled && !_isPubGlobalActivated(pathToScript)) {
        pathToScript = Platform.resolvedExecutable;
      }
    } else {
      /// when running in a unit test we can end up with a 'data' scheme
      if (script.isScheme('data')) {
        final start = script.path.indexOf('file:');
        final end = script.path.lastIndexOf('.dart');
        final fileUri = script.path.substring(start, end + 5);

        /// now parse the remaining uri to a path.
        pathToScript = Uri.parse(fileUri).toFilePath();
      } else {
        pathToScript = pwd;
      }
    }

    _pathToScript = truepath(pathToScript);
    _scriptName = p.basename(truepath(pathToScript));
    _scriptDirectory = dirname(truepath(pathToScript));
  }

  /// Creates a [DartScript] object from a dart script
  /// located at [scriptPathTo].
  ///
  /// The [scriptPathTo] may be a filename or
  /// a filename with a path prefix (relative or absolute).
  /// The [scriptPathTo] parameter MUST end with '.dart'
  ///
  /// If the path is relative then it will be joined
  /// with the current working directory to form
  /// a absolute path.
  ///
  /// To obtain a [DartScript] instance for your running application call:
  ///
  /// ```dart
  /// var script = DartScript.current;
  /// ```
  ///
  DartScript.fromFile(String scriptPathTo, {DartProject? project})
      : this._internal(scriptPathTo, project: project);

  DartScript._internal(
    String pathToScript, {
    DartProject? project,
  })  : _pathToScript = truepath(pathToScript),
        _scriptDirectory = dirname(truepath(pathToScript)),
        _project = project {
    {
      verbose(() => '_pathToScript: $_pathToScript');
      _scriptName = p.basename(truepath(pathToScript));
    }
  }

  /// Returns the instance of the currently running script.
  ///
  /// If you are trying to load an instace of another script then
  /// use [DartScript.fromFile];
  // ignore: flutter_style_todos
  /// TODO(bsutton): for v2 change this to a ctor to aid with unit testing.
  // ignore: prefer_constructors_over_static_methods
  static DartScript get self => _current ??= DartScript._self();

  /// Name of the dart script
  late final String _scriptName;

  /// Path to the dart script loaded.
  late final String _pathToScript;

  /// The directory where the dart script file lives
  /// stored as an absolute path.
  late final String _scriptDirectory;

  /// Absolute path to 'this' script including the script name
  ///
  /// If this is a .dart file then its current location.
  /// If this is a compiled script then the location of the compiled exe.
  /// If the script was globally activated then this will be a path
  /// to the script in the pub-cache.
  String get pathToScript => _pathToScript;

  /// The filename of the script including the extension.
  /// If you are running in a compiled script then
  /// [scriptName] won't have a '.dart' extension.
  /// In a compiled script the extension generally depends on the OS but
  /// it could in theory be anything (except for .dart).
  /// Common extensions are .exe for windows and no extension for Linux
  /// and MacOS.
  String get scriptName => _scriptName;

  /// the absolute path to the directory the script lives in
  String get pathToScriptDirectory => _scriptDirectory;

  /// the name of the script without its extension.
  /// this is used for the 'name' key in the pubspec.
  String get pubsecNameKey => p.basenameWithoutExtension(scriptName);

  /// The scriptname without its '.dart' extension.
  String get basename => p.basenameWithoutExtension(scriptName);

  /// Returns the path to a scripts pubspec.yaml.
  /// The pubspec.yaml is located in the project's root directory.
  String get pathToPubSpec => project.pathToPubSpec;

  /// True if the script has been compiled or pre-compiled via a pub get.
  bool get isReadyToRun => _isCompiled || project.isReadyToRun;

  /// True if the script is compiled.
  bool get isCompiled => _isCompiled;

  static bool get _isCompiled =>
      p.extension(Platform.script.toFilePath()) != '.dart' &&
      !_isPubGlobalActivated(Platform.script.toFilePath());

  String? _unitTestPath;

  /// Returns true if we are running in a unit test.
  /// We do this by inspecting the stack looking for the test_api package
  /// so this method has very limited use and is intended for
  /// internal dcli testing.
  @visibleForTesting
  bool get inUnitTest {
    Frame? scriptFrame;
    for (final frame in Trace.current().frames) {
      if (frame.package != null && frame.package == 'test_api') {
        if (scriptFrame != null) {
          _unitTestPath = truepath(scriptFrame.library);
        }
        return true;
      }
      scriptFrame = frame;
    }

    return false;
    // p.extension(Platform.script.toFilePath()) == '.dill' &&
    //     p.basenameWithoutExtension(Platform.script.toFilePath()) ==
    //         'test.dart_1';
  }

  /// Checks if the Script has been compiled and installed into the ~/.dcli/bin path
  bool get isInstalled => exists(pathToInstalledExe);

  /// True if the script has been installed via 'dart pub global active'
  /// and as such is running from the pub cache.
  bool get isPubGlobalActivated => _isPubGlobalActivated(_pathToScript);

  static bool _isPubGlobalActivated(String pathToScript) =>
      pathToScript.startsWith(PubCache().pathTo);

  /// The current script that is running.
  static DartScript? _current;

  ///
  @Deprecated('Use DartScript.self or DartScript.fromPath()')
  static DartScript get current => self;

  /// Strips the root prefix of a path so we can use
  /// it as part of the virtual projects path.
  /// For linux this just removes any leading /
  /// For windows this removes c:\
  static String sansRoot(String path) =>
      path.substring(p.rootPrefix(path).length);

  /// Determines the script project root.
  /// The project root is defined as the directory which contains
  /// the scripts 'pubspec.yaml' file.
  ///
  /// If the script is compiled or installed by pub global activate
  /// then this will be the location of the script file.
  String get pathToProjectRoot => project.pathToProjectRoot;

  DartProject? _project;

  /// the project for this scrtipt.
  DartProject get project =>
      _project ??= DartProject.fromPath(pathToScriptDirectory);

  /// used by the 'doctor' command to prints the details for this project.
  void get doctor {
    print('');
    print('');
    print('Dart Script Details');
    _colprint('Name', scriptName);
    _colprint('Directory', privatePath(pathToScriptDirectory));
  }

  void _colprint(String label, String value, {int pad = 25}) {
    print('${label.padRight(pad)}: $value');
  }

  ///
  /// reads and returns the project's virtual pubspec
  /// and returns it.
  PubSpec get pubSpec => project.pubSpec;

  /// Compiles this script and optionally installs it to ~/.dcli/bin
  ///
  /// The resulting executable is compiled into the script's directory.
  ///
  /// If [install] is true (default = false) then the resulting executable will be moved into ~/.dcli/bin.
  ///
  /// If [install] is true and [overwrite] is true (default) it will overwrite any existing exe in ~/.dcli/bin.
  /// If [install] is true and [overwrite] is false and an exe of the same name already exists in ~/.dcli/bin
  /// the install will fail and a [MoveException] will be thrown.
  ///
  /// If [workingDirectory] is not passed then the current working directory is
  /// used. The [workingDirectory] should contain the pubspec.yaml that is used
  /// to compile the script.
  void compile({
    bool install = false,
    bool overwrite = false,
    String? workingDirectory,
  }) {
    verbose(
      () => '\nCompiling with pubspec.yaml:\n'
          '${read(pathToPubSpec).toParagraph()}\n',
    );

    workingDirectory ??= pwd;

    if (install && isInstalled && !overwrite) {
      throw InvalidArgumentException(
        'You selected to install the compiled exe however an installed '
        'exe of that name already exists. Use overwrite=true',
      );
    }

    DartSdk().runDartCompiler(
      this,
      pathToExe: pathToExe,
      progress: Progress(print, stderr: print),
      workingDirectory: workingDirectory,
    );

    if (install) {
      print('');
      print(orange('Installing $pathToExe into $pathToInstalledExe'));
      move(pathToExe, pathToInstalledExe, overwrite: true);
    }
  }

  /// Runs the dart script with an optional set of [args].
  ///
  /// [args] is a list of command line arguments which will
  /// be passed to the scsript.
  ///
  /// Returns the processes exit code.
  int run({List<String> args = const <String>[]}) {
    final sdk = DartSdk();

    final runner = ScriptRunner(sdk, this, args);

    return runner.run();
  }

  /// Runs the dart script with an optional set of [args].
  ///
  /// [args] is a list of command line arguments which will
  /// be passed to the scsript.
  ///
  /// Returns the processes exit code.
  Progress start({
    List<String> args = const <String>[],
    Progress? progress,
    bool runInShell = false,
    bool detached = false,
    bool terminal = false,
    bool privileged = false,
    bool nothrow = false,
    String? workingDirectory,
    bool extensionSearch = true,
  }) {
    final sdk = DartSdk();

    final runner = ScriptRunner(sdk, this, args);

    return runner.start(
        progress: progress,
        runInShell: runInShell,
        detached: detached,
        terminal: terminal,
        privileged: privileged,
        nothrow: nothrow,
        workingDirectory: workingDirectory,
        extensionSearch: extensionSearch);
  }

  /// Returns the platform dependant name of the compiled script's exe name.
  /// On Linux and MacOS this is just the basename (script name
  ///  without the extension)
  /// on Windows this is the 'basename.exe'.
  String get exeName => '$basename${Settings().isWindows ? '.exe' : ''}';

  /// Returns the path to the executable if it was to be compiled into
  /// its local directory (the default action of compile).
  String get pathToExe => join(pathToScriptDirectory, exeName);

  /// Returns the path that the script would be installed to if
  /// compiled with dcli with the --install switch.
  String get pathToInstalledExe => join(Settings().pathToDCliBin, exeName);

  /// internal method do not use.
  @visibleForTesting
  static String stripDartVersionSuffix(String pathToCurrentScript) {
    var result = pathToCurrentScript;

    /// Not certain what is going on here.
    /// If we use a pub global activated version then
    /// Platform.script is returning a filename of the form:
    /// pub_release.dart-2.13.0.snapshot
    /// So we look to strip of the suffix from the - onward.
    if (pathToCurrentScript.contains('.dart-')) {
      var index = pathToCurrentScript.indexOf('.dart-');
      index += 5;
      result = pathToCurrentScript.substring(0, index);
    }

    return result;
  }

  /// Runs pub get in the script's DartProject folder.
  void runPubGet() {
    DartSdk().runPubGet(project.pathToProjectRoot);
  }
}

// ignore: avoid_classes_with_only_static_members
///
class PithyGreetings {
  ///
  static List<String> greeting = [
    'Hello World',
    'Helwo vorld',
    'Build and Ben flower pot men. Weeeeeeeed.',
    "I'm a little tea pot.",
    'Are we there yet.',
    'Hurry up, says Mr Blackboard',
    "Damned if you do, Damned if you don't, so just get the hell on with it.",
    'Yep, this is all of it.',
    "I don't like your curtains"
  ];

  /// returns a random pithy greeting.
  static String random() {
    final selected = Random().nextInt(greeting.length - 1);

    return greeting[selected];
  }
}
