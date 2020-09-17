import 'dart:io';
import 'dart:math';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/pubspec/pubspec.dart';
import 'package:dcli/src/script/runner.dart';
import 'package:dcli/src/settings.dart';
import 'package:path/path.dart' as p;

import '../functions/is.dart';
import 'dart_project.dart';

import 'command_line_runner.dart';

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
  /// The [scriptPath] may be a filename or
  /// a filename with a path prefix (relative or absolute)
  /// If the path is realtive then it will be joined
  /// with the current working directory to form
  /// a absolute path.
  ///
  /// To obtain a [Script] instance for your cli application call:
  ///
  /// ```dart
  /// var script = Script.fromFile(Platform.script.toFilePath());
  ///
  Script.fromFile(String scriptPath, {DartProject project})
      : this._internal(scriptPath,
            create: false, showWarnings: false, project: project);

  Script._internal(String scriptPath,
      {bool create, bool showWarnings, DartProject project})
      : _scriptname = _extractScriptname(scriptPath),
        _scriptDirectory = _extractScriptDirectory(scriptPath),
        _project = project {
    {
      assert(scriptPath.endsWith('.dart'));
      if (create) {
        var project = DartProject.fromPath(pathToProjectRoot);
        project.initFiles();
      }
    }
  }

  /// the file name of the script including the extension.
  /// If you are running in a compiled script then
  /// [scriptname] won't have a '.dart' extension.
  /// In an compiled script the extension generally depends on the OS but
  /// it could in theory be anything (except for .dart).
  /// Common extensions are .exe for windows and no extension for Linux and OSx.
  String get scriptname => _scriptname;

  /// the absolute path to the directory the script lives in
  String get pathToScriptDirectory => _scriptDirectory;

  /// the absolute path of the script file.
  String get pathToScript => p.join(pathToScriptDirectory, scriptname);

  /// the name of the script without its extension.
  /// this is used for the 'name' key in the pubspec.
  String get pubsecNameKey => p.basenameWithoutExtension(scriptname);

  /// The scriptname without its '.dart' extension.
  String get basename => p.basenameWithoutExtension(scriptname);

  // /// the path to a scripts local pubspec.yaml.
  // /// Only a script that has a pubspec.yaml in the same directory as the script
  // /// will have a pubspec.yaml at this location.
  // ///
  // /// You should use [VirtualProject.projectPubspecPath] as that will always point
  // /// the the correct pubspec.yaml regardless of the project type.
  // String get pathToLocalPubSpec => p.join(_scriptDirectory, 'pubspec.yaml');

  /// Returns the path to a scripts pubspec.yaml.
  /// The pubspec.yaml is located in the project's root directory.
  String get pathToPubSpec => project.pathToPubSpec;

  bool get isReadyToRun => project.isReadyToRun;

  // the scriptnameArg may contain a relative path: fred/home.dart
  // we need to get the actually name and full path to the script file.
  static String _extractScriptname(String scriptArg) {
    var cwd = Directory.current.path;

    return p.basename(p.join(cwd, scriptArg));
  }

  // /// Returns true if the script has a pubspec.yaml in its directory.
  // bool hasLocalPubspecYaml() {
  //   // The virtual project pubspec.yaml file.
  //   final pubSpecPath = p.join(_scriptDirectory, 'pubspec.yaml');
  //   return exists(pubSpecPath);
  // }

  // /// returns true if the script has a pubspec in anscestor directory.
  // ///
  // bool hasAncestorPubspecYaml() {
  //   return pathToProjectRoot != _scriptDirectory;
  // }

  static String _extractScriptDirectory(String scriptArg) {
    var scriptDirectory = p.canonicalize(p.dirname(p.join(pwd, scriptArg)));

    return scriptDirectory;
  }

  /// validate that the passed arguments points to a valid script
  static void validate(String scriptPath) {
    if (!scriptPath.endsWith('.dart')) {
      throw InvalidArguments(
          'Expected a script name (ending in .dart) instead found: $scriptPath');
    }

    if (!exists(scriptPath)) {
      throw InvalidScript(
          'The script ${p.absolute(scriptPath)} does not exist.');
    }
    if (!FileSystemEntity.isFileSync(scriptPath)) {
      throw InvalidScript(
          'The script ${p.absolute(scriptPath)} is not a file.');
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
  /// For a script which contains a @pubspec annotation or
  /// a script which doesn't have a pubspec.yaml
  /// this is the same directory that the script lives in.
  ///
  ///
  String get pathToProjectRoot => project.pathToProjectRoot;

  static Script _current;

  /// Returns the instance of the currently running script.
  ///
  static Script get current {
    _current ??= Script.fromFile(Settings().pathToScript);
    return _current;
  }

  DartProject _project;

  DartProject get project =>
      _project ??= DartProject.fromPath(pathToScriptDirectory, search: true);

  bool get isCompiled => !scriptname.endsWith('.dart');

  /// used by the 'doctor' command to prints the details for this project.
  void get doctor {
    print('');
    print('');
    print('Script Details');
    _colprint('Name', scriptname);
    _colprint('Directory', privatePath(pathToScriptDirectory));

    project.doctor;
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

    var pathToExe = basename;

    DartSdk().runDart2Native(this,
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

    return runner.exec();
  }

  /// returns the platform dependant name of the compiled scripts exe name.
  /// On Linux and OSX this is just the basename (script name without the extension)
  /// on Windows this is the 'basename.exe'.
  String get exeName => '${basename}${Settings().isWindows ? '.exe' : ''}';

  /// Returns the path to the executable if it was to be compiled into
  /// its local directory (the default action of compile).
  String get exePath => join(pathToScriptDirectory, exeName);

  /// Checks if the Script has been compiled and installed into the ~/.dcli/bin path
  bool get isInstalled {
    return exists(pathToInstalledExe);
  }

  /// Returns the path that the script would be installed to if compiled with [install] = true.
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
    var selected = Random().nextInt(greeting.length - 1);

    return greeting[selected];
  }
}
