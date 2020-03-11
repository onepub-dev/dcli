import 'dart:io';

import '../../../dshell.dart';
import '../../functions/is.dart';
import '../flags.dart';

import 'package:path/path.dart' as p;

import '../command_line_runner.dart';
import '../script.dart';
import '../virtual_project.dart';
import 'commands.dart';

class CreateCommand extends Command {
  static const String NAME = 'create';

  List<Flag> createFlags = [ForegroundFlag()];

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  Script _script;

  CreateCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    _initTemplates();

    var scriptIndex = 0;

    // check for any flags
    for (var i = 0; i < subarguments.length; i++) {
      final subargument = subarguments[i];

      if (Flags.isFlag(subargument)) {
        var flag = flagSet.findFlag(subargument, createFlags);

        if (flag != null) {
          if (flagSet.isSet(flag)) {
            throw DuplicateOptionsException(subargument);
          }
          flagSet.set(flag);
          Settings().verbose('Setting flag: ${flag.name}');
          continue;
        } else {
          throw UnknownFlag(subargument);
        }
      }
      scriptIndex = i;

      _script =
          validateArguments(selectedFlags, subarguments.sublist(scriptIndex));
      break;
    }

    var body = _script.generateDefaultBody();
    _script.createDefaultFile(body);

    print('Creating project...');
    var project = VirtualProject.create(_script);
    project.build(background: !flagSet.isSet(ForegroundFlag()));

    if (!Platform.isWindows) {
      chmod(755, p.join(_script.scriptDirectory, _script.scriptname));
    }

    print('');

    print('To run your script:\n   ./${_script.scriptname}');

    return 0;
  }

  Script validateArguments(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.length != 1) {
      throw InvalidArguments(
          'The create command takes only one argument. Found: ${arguments.join(',')}');
    }
    var scriptName = arguments[0];
    if (extension(scriptName) != '.dart') {
      throw InvalidArguments(
          "The create command expects a script name ending in '.dart'. Found: ${scriptName}");
    }

    if (exists(scriptName)) {
      throw InvalidArguments(
          'The script ${truepath(scriptName)} already exists.');
    }
    return Script.fromFile(arguments[0]);
  }

  /// Checks if the templates directory exists and .dshell and if not creates
  /// the directory and copies the default scripts in.
  void _initTemplates() {
    if (!exists(Settings().templatePath)) {
      createDir(Settings().templatePath, recursive: true);
    }
  }

  @override
  String description() =>
      'Creates a script file with a default pubspec annotation and a main entry point.';

  @override
  String usage() => 'create [--foreground] <script path.dart>';

  @override
  List<String> completion(String word) {
    return <String>[];
  }

  @override
  List<Flag> flags() {
    return createFlags;
  }
}

class ForegroundFlag extends Flag {
  static const NAME = 'foreground';

  ForegroundFlag() : super(NAME);

  @override
  String get abbreviation => 'fg';

  @override
  String description() {
    return '''Stops the create from running pub get in the background.''';
  }
}
