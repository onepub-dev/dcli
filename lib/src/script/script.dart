import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

import '../../dcli.dart';
import '../functions/is.dart';
import '../pubspec/pubspec.dart';
import '../settings.dart';
import 'command_line_runner.dart';
import 'dart_project.dart';
import 'runner.dart';

/// Used to manage a DCli script.
///
/// This class is primarily for internal use.
///
/// We expose [Script] as it permits some self discovery
/// of the script you are currently running.
///
///
class Script {
  /// Creates a script object from a scriptArg
  /// passed to a command.
  ///
  /// The [scriptPathTo] may be a filename or
  /// a filename with a path prefix (relative or absolute)
  /// If the path is realtive then it will be joined
  /// with the current working directory to form
  /// a absolute path.
  ///
  /// To obtain a [Script] instance for your running application call:
  ///
  /// ```dart
  /// var script = Script.current;
  /// ```
  ///
  Script.fromFile(String scriptPathTo, {DartProject? project})
      : this._internal(scriptPathTo, create: false, project: project);

  Script._internal(String pathToScript,
      {required bool create, DartProject? project})
      : _pathToScript = truepath(pathToScript),
        _scriptname = p.basename(truepath(pathToScript)),
        _scriptDirectory = dirname(truepath(pathToScript)),
        _project = project {
    {
      if (create) {
        DartProject.fromPath(pathToProjectRoot).initFiles();
      }
    }
  }

  /// The directory where the script file lives
  /// stored as an absolute path.
  final String _scriptDirectory;

  /// Name of the dart script
  final String _scriptname;

  /// Path to the script loaded.
  String _pathToScript;

  /// path to the this script.
  String get pathToScript => _pathToScript;

  /// The filename of the script including the extension.
  /// If you are running in a compiled script then
  /// [scriptname] won't have a '.dart' extension.
  /// In a compiled script the extension generally depends on the OS but
  /// it could in theory be anything (except for .dart).
  /// Common extensions are .exe for windows and no extension for Linux and OSx.
  String get scriptname => _scriptname;

  /// the absolute path to the directory the script lives in
  String get pathToScriptDirectory => _scriptDirectory;

  /// the name of the script without its extension.
  /// this is used for the 'name' key in the pubspec.
  String get pubsecNameKey => p.basenameWithoutExtension(scriptname);

  /// The scriptname without its '.dart' extension.
  String get basename => p.basenameWithoutExtension(scriptname);

  /// Returns the path to a scripts pubspec.yaml.
  /// The pubspec.yaml is located in the project's root directory.
  String get pathToPubSpec => project.pathToPubSpec;

  /// True if the script has been pre-compiled via a pub get.
  bool get isReadyToRun => project.isReadyToRun;

  /// True if the script is compiled.
  bool get isCompiled => _isCompiled;

  static bool get _isCompiled =>
      p.basename(Platform.resolvedExecutable) ==
      p.basename(Platform.script.path);

  /// Checks if the Script has been compiled and installed into the ~/.dcli/bin path
  bool get isInstalled => exists(pathToInstalledExe);

  /// True if the script has been installed via 'dart pub global active'
  /// and as such is running from the pub cache.
  bool get isPubGlobalActivated => _pathToScript.startsWith(PubCache().pathTo);

  /// The current script that is running.
  static Script? _current;

  /// Returns the instance of the currently running script.
  ///
  // ignore: prefer_constructors_over_static_methods
  static Script get current =>
      _current ??= Script.fromFile(_pathToCurrentScript);

  /// Path to the currently runnng script
  static String? __pathToCurrentScript;

  /// Absolute path to 'this' script.
  /// If this is a .dart file then its current location.
  /// If this is a compiled script then the location of the compiled exe.
  /// If the script was globally activated then this will be a path
  /// to the script in the pub-cache.
  static String get _pathToCurrentScript {
    if (__pathToCurrentScript == null) {
      final script = Platform.script;

      if (script.isScheme('file')) {
        __pathToCurrentScript = Platform.script.path;

        if (_isCompiled) {
          __pathToCurrentScript = Platform.resolvedExecutable;
        }
      } else {
        /// when running in a unit test we can end up with a 'data' scheme
        if (script.isScheme('data')) {
          final start = script.path.indexOf('file:');
          final end = script.path.lastIndexOf('.dart');
          final fileUri = script.path.substring(start, end + 5);

          /// now parse the remaining uri to a path.
          __pathToCurrentScript = Uri.parse(fileUri).toFilePath();
        } else {
          __pathToCurrentScript = pwd;
        }
      }
    }

    return __pathToCurrentScript!;
  }

  /// validate that the passed arguments points to a valid script
  static void validate(String scriptPath) {
    if (!scriptPath.endsWith('.dart')) {
      throw InvalidArguments('Expected a script name (ending in .dart) '
          'instead found: $scriptPath');
    }

    if (!exists(scriptPath)) {
      throw InvalidScript('The script ${truepath(scriptPath)} does not exist.');
    }
    if (!FileSystemEntity.isFileSync(scriptPath)) {
      throw InvalidScript('The script ${truepath(scriptPath)} is not a file.');
    }
  }

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
    print('Script Details');
    _colprint('Name', scriptname);
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
  void compile({bool install = false, bool overwrite = false}) {
    Settings().verbose('\nCompiling with pubspec.yaml:\n'
        "${read(pathToPubSpec).toList().join('\n')}\n");

    if (install && isInstalled && !overwrite) {
      throw InvalidArguments(
          'You selected to install the compiled exe however an installed '
          'exe of that name already exists. Use overwrite=true');
    }

    DartSdk().runDartCompiler(this,
        pathToExe: pathToExe, progress: Progress(print, stderr: print));

    if (install) {
      print('');
      print(orange('Installing $pathToExe into $pathToInstalledExe'));
      move(pathToExe, pathToInstalledExe, overwrite: true);
    }
  }

  /// Runs the script passing in the given [args]
  ///
  /// Returns the processes exit code.
  int run(List<String> args) {
    final sdk = DartSdk();

    final runner = ScriptRunner(sdk, this, args);

    return runner.run();
  }

  /// Returns the platform dependant name of the compiled script's exe name.
  /// On Linux and OSX this is just the basename (script name
  ///  without the extension)
  /// on Windows this is the 'basename.exe'.
  String get exeName => '$basename${Settings().isWindows ? '.exe' : ''}';

  /// Returns the path to the executable if it was to be compiled into
  /// its local directory (the default action of compile).
  String get pathToExe => join(pathToScriptDirectory, exeName);

  /// Returns the path that the script would be installed to if
  /// compiled with install = true.
  String get pathToInstalledExe => join(Settings().pathToDCliBin, exeName);
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
