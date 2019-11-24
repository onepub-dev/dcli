import 'dart:io';
import 'dart:math';

import 'package:dshell/script/flags.dart';
import 'package:dshell/util/file_helper.dart';
import 'package:path/path.dart' as p;

import 'command_line_runner.dart';

class Script {
  /// The directory where the script file lives
  /// stored as an absolute path.
  final String _scriptDirectory;

  /// Name of the dart script
  final String _scriptname;

  List<Flag> flags;

  /// Creates a script object from a scriptArg
  /// passed to a command.
  ///
  /// The scriptArg may be a filename or
  /// a filename with a path prefix (relative or absolute)
  /// If the path is realtive then it will be joined
  /// with the current working directory to form
  /// a absolute path.
  Script.fromArg(
    this.flags,
    String scriptArg,
  )   : _scriptname = _extractScriptname(scriptArg),
        _scriptDirectory = _extractScriptDirectory(scriptArg);

  /// the file name of the script including the extension.
  String get scriptname => _scriptname;

  /// the absolute path to the directory the script lives in
  String get scriptDirectory => _scriptDirectory;

  /// the absolute path of the script file.
  String get path => p.join(scriptDirectory, scriptname);

  /// the name of the script without its extension.
  /// this is used for the 'name' key in the pubspec.
  String get pubsecName => p.basenameWithoutExtension(scriptname);

  /// The scriptname without its '.dart' extension.
  String get basename => p.basenameWithoutExtension(scriptname);

  // the scriptnameArg may contain a relative path: fred/home.dart
  // we need to get the actually name and full path to the script file.
  static String _extractScriptname(String scriptArg) {
    String cwd = Directory.current.path;

    return p.basename(p.join(cwd, scriptArg));
  }

  static String _extractScriptDirectory(String scriptArg) {
    String cwd = Directory.current.path;

    String scriptDirectory = p.canonicalize(p.dirname(p.join(cwd, scriptArg)));

    return scriptDirectory;
  }

  /// Generates the default scriptfile contents
  ///
  void createDefaultFile(String appname, String defaultBody) {
    writeToFile(path, defaultBody);
  }

  String generateDefaultBody(String appname) {
    /// The default body of the script we generate.
    return """#! /usr/bin/env $appname
/*
@pubspec.yaml
name: $scriptname
dependencies:
  dshell: ^1.0.0
  money2: ^1.0.0
*/

import 'dart:io';
import 'package:dshell/dshell.dart';
import 'package:path/path.dart' as p;
import 'package:money2/money2.dart';


void main() {
  print("${PithyGreetings.random()});
    }
""";
  }

  /// validate that the passed arguments points to
  /// a valid script.
  /// The script name MUST be the first argument.
  ///
  /// Throws an exception if the script is invalid.
  static void validate(List<String> arguments) {
    if (arguments.isEmpty) {
      throw InvalidArguments(
          "Expected a script or command. No arguments were found");
    }

    String scriptArg = arguments[0];
    if (!scriptArg.endsWith(".dart")) {
      throw InvalidArguments(
          "Expected a script name instead found: ${scriptArg}");
    }

    if (!File(scriptArg).existsSync()) {
      throw InvalidScript(
          "The script ${p.absolute(scriptArg)} does not exist.");
    }
    if (!FileSystemEntity.isFileSync(scriptArg)) {
      throw InvalidScript("The script ${p.absolute(scriptArg)} is not a file.");
    }
  }

  void run(Map<String, Flag> selectedFlags, List<String> subarguments) {}
}

class PithyGreetings {
  static List<String> greeting = [
    "Hello World",
    "Helwo vorld",
    "Build and Ben flower pot men. Weeeeeeeed.",
    "I'm a little tea pot.",
    "Are we there yet.",
    "Hurry up, says Mr Blackboard",
    "Damed if you do, Damed if you don't, so just get the hell on with it.",
    "Yep, this is all of it.",
    "I don't like your curtains"
  ];

  /// returns a random pithy greeting.
  static String random() {
    int selected = Random().nextInt(greeting.length - 1);

    return greeting[selected];
  }
}
