import 'dart:io';
import 'dart:math';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/pubspec/pubspec.dart';
import 'package:dcli/src/script/runner.dart';
import 'package:dcli/src/settings.dart';
import 'package:path/path.dart' as p;

import '../functions/is.dart';
import 'command_line_runner.dart';
import 'dart_project.dart';

/// Used to manage a DCli script.
///
/// This class is primarily for internal use.
///
/// We expose [Script] as it permits some self discovery
/// of the script you are currently running.
///
///
class Script {
  /// The directory where the script file lives
  /// stored as an absolute path.
  final String _scriptDirectory;

  /// Name of the dart script
  final String _scriptname;

  /// Creates a script object from a scriptArg
  /// passed to a command.
  ///
  /// The [scriptPathTo] may be a filename or
  /// a filename with a path prefix (relative or absolute)
  ///
  /// To obtain a [Script] instance for your running application call:
  ///
  /// ```dart
  /// var script = Script.current;
  /// ```
  ///
  Script.fromFile(String scriptPathTo, {DartProject project})
      : this._internal(scriptPathTo, create: false, project: project);

  Script._internal(String pathToScript, {bool create, DartProject project})
      : _pathToScript = truepath(pathToScript),
        _scriptname = p.basename(truepath(pathToScript)),
        _scriptDirectory = dirname(truepath(pathToScript)),
        _project = project {
    {
      assert(pathToScript.endsWith('.dart'));
      if (create) {
        final project = DartProject.fromPath(pathToProjectRoot);
        project.initFiles();
      }
    }
  }

  String _pathToScript;

  /// Absolute path to this script.
  /// If this is a .dart file then its current location.
  /// If this is a compiled script then the location of the compiled exe.
  /// If the script was globally activated then this will be a path
  /// to the script in the pub-cache.
  String get pathToScript => _pathToScript;

  /// the file name of the script including the extension.
  /// If you are running in a compiled script then
  /// [scriptname] won't have a '.dart' extension.
  /// In an compiled script the extension generally depends on the OS but
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

  bool get isReadyToRun => project.isReadyToRun;

  /// True if the script is compiled.
  bool get isCompiled => !scriptname.endsWith('.dart');

  /// Checks if the Script has been compiled and installed into the ~/.dcli/bin path
  bool get isInstalled {
    return exists(pathToInstalledExe);
  }

  /// True if the script has been installed via 'dart pub global active'
  /// and as such is running from the pub cache.
  bool get isPubGlobalActivated => pathToScript.startsWith(PubCache().pathTo);

  /// The current script that is running.
  static Script _current;

  /// Returns the instance of the currently running script.
  ///
  // ignore: prefer_constructors_over_static_methods
  static Script get current =>
      _current ??= Script.fromFile(_pathToCurrentScript);

  /// The absolute path to the dcli script which
  /// is currently running.
  static String get _pathToCurrentScript {
    if (_current == null) {
      final script = Platform.script;

      String _pathToScript;
      if (script.isScheme('file')) {
        _pathToScript = Platform.script.toFilePath();
      } else {
        /// when running in a unit test we can end up with a 'data' scheme
        if (script.isScheme('data')) {
          final start = script.path.indexOf('file:');
          final end = script.path.lastIndexOf('.dart');
          final fileUri = script.path.substring(start, end + 5);

          /// now parse the remaining uri to a path.
          _pathToScript = Uri.parse(fileUri).toFilePath();
        }
      }

      return _pathToScript;
    } else {
      return _current.pathToScript;
    }
  }

  /// validate that the passed arguments points to a valid script
  static void validate(String scriptPath) {
    if (!scriptPath.endsWith('.dart')) {
      throw InvalidArguments(
          'Expected a script name (ending in .dart) instead found: $scriptPath');
    }

    if (!exists(scriptPath)) {
      throw InvalidScript(
          'The script ${truepath(scriptPath)} does not exist.');
    }
    if (!FileSystemEntity.isFileSync(scriptPath)) {
      throw InvalidScript(
          'The script ${truepath(scriptPath)} is not a file.');
    }
  }

  /// Strips the root prefix of a path so we can use
  /// it as part of the virtual projects path.
  /// For linux this just removes any leading /
  /// For windows this removes c:\
  static String sansRoot(String path) {
    return path.substring(p.rootPrefix(path).length);
  }

  /// Determines the script project root.
  /// The project root is defined as the directory which contains
  /// the scripts 'pubspec.yaml' file.
  ///
  /// If the script is compiled or installed by pub global activate
  /// then this will be the location of the script file.
  String get pathToProjectRoot => project.pathToProjectRoot;

  DartProject _project;

  DartProject get project =>
      _project ??= DartProject.fromPath(pathToScriptDirectory, search: true);

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

  void compile({bool install = false, bool overwrite = false}) {
    Settings().verbose(
        "\nCompiling with pubspec.yaml:\n${read(pathToPubSpec).toList().join('\n')}\n");

    if (install && isInstalled && !overwrite) {
      throw InvalidArguments(
          'You selected to install the compiled exe however an installed exe of that name already exists. Use overwrite=true');
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

  /// returns the platform dependant name of the compiled scripts exe name.
  /// On Linux and OSX this is just the basename (script name without the extension)
  /// on Windows this is the 'basename.exe'.
  String get exeName => '$basename${Settings().isWindows ? '.exe' : ''}';

  /// Returns the path to the executable if it was to be compiled into
  /// its local directory (the default action of compile).
  String get pathToExe => join(pathToScriptDirectory, exeName);

  /// Returns the path that the script would be installed to if compiled with install = true.
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
    "Damed if you do, Damed if you don't, so just get the hell on with it.",
    'Yep, this is all of it.',
    "I don't like your curtains"
  ];

  /// returns a random pithy greeting.
  static String random() {
    final selected = Random().nextInt(greeting.length - 1);

    return greeting[selected];
  }
}
