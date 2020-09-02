import 'package:path/path.dart' as p;

import '../../../dcli.dart';

import '../../functions/is.dart';
import '../command_line_runner.dart';
import '../flags.dart';

import '../script.dart';
import '../virtual_project.dart';
import 'commands.dart';

/// implementation of the 'create' command
class CreateCommand extends Command {
  static const String _commandName = 'create';

  final _createFlags = [ForegroundFlag()];

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  Script _script;

  ///
  CreateCommand() : super(_commandName);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var scriptIndex = 0;

    // check for any flags
    for (var i = 0; i < subarguments.length; i++) {
      final subargument = subarguments[i];

      if (Flags.isFlag(subargument)) {
        var flag = flagSet.findFlag(subargument, _createFlags);

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

      var scriptPath =
          _validateArguments(selectedFlags, subarguments.sublist(scriptIndex));

      Script.createFromTemplate(
        templatePath: join(Settings().pathToTemplate, 'cli_args.dart'),
        scriptPath: scriptPath,
      );

      _script = Script.init(scriptPath);

      break;
    }

    print('Creating project...');
    var project = VirtualProject.create(_script);
    project.build(background: !flagSet.isSet(ForegroundFlag()));

    if (!Settings().isWindows) {
      chmod(755, p.join(_script.pathToScriptDirectory, _script.scriptname));
    }

    print('');

    print('To run your script:\n   ./${_script.scriptname}');

    return 0;
  }

  /// returns the script path.
  String _validateArguments(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.length != 1) {
      throw InvalidArguments(
          'The create command takes only one argument. Found: ${arguments.join(',')}');
    }
    var scriptPath = arguments[0];
    if (extension(scriptPath) != '.dart') {
      throw InvalidArguments(
          "The create command expects a script path ending in '.dart'. Found: $scriptPath");
    }

    if (exists(scriptPath)) {
      throw InvalidArguments(
          'The script ${truepath(scriptPath)} already exists.');
    }
    return arguments[0];
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
    return _createFlags;
  }
}

///
class ForegroundFlag extends Flag {
  static const _flagName = 'foreground';

  ///
  ForegroundFlag() : super(_flagName);

  @override
  String get abbreviation => 'fg';

  @override
  String description() {
    return '''Stops the create from running pub get in the background.''';
  }
}
