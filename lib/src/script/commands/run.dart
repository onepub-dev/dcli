import 'dart:io';

import '../../../dcli.dart';
import '../../settings.dart';
import '../../util/completion.dart';

import '../command_line_runner.dart';
import '../dart_sdk.dart';
import '../flags.dart';
import '../runner.dart';
import '../script.dart';
import '../dart_project.dart';
import 'commands.dart';

/// Runs a dart script.
/// If required a virtual project is created
/// and built.
class RunCommand extends Command {
  static const String _commandName = 'run';

  ///
  RunCommand() : super(_commandName);

  ///
  ///
  /// [arguments] - the arguments passed directly to the run command.
  /// Returns the [exitcode];
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.isEmpty) {
      throw InvalidArguments(
          'Expected a script or command. No arguments were found.');
    }
    var scriptPath = arguments[0];
    Script.validate(scriptPath);

    var script = Script.fromFile(scriptPath);

    if (Shell.current.isSudo) {
      /// we are running sudo, so we can't init a script
      /// as we will end up with root permissions everywhere.
      if (!script.isReadyToRun) {
        printerr(red(
            'The script is not ready to run, so cannot be run from sudo. Run dcli clean $scriptPath'));
        exit(1);
      }
    }

    Settings().pathToScript = script.pathToScript;

    Settings().verbose('Running script ${script.pathToScript}');

    if (!script.isReadyToRun) {
      if (Shell.current.isSudo) {
        printerr(red(
            'The script is not ready to run, so cannot be run from sudo. Run dcli clean $scriptPath'));
        exit(1);
      } else {
        var project = DartProject.fromPath(script.pathToScriptDirectory);
        
      }
    }

    var scriptArguments = <String>[];

    if (arguments.length > 1) {
      scriptArguments = arguments.sublist(1);
    }

    Settings().verbose('Script Arguments: ${scriptArguments.join(", ")}');

    final sdk = DartSdk();

    final runner = ScriptRunner(sdk, script, scriptArguments);

    final exitCode = runner.exec();

    return exitCode;
  }

  @override
  String usage() => 'run <script path.dart>';

  @override
  String description() =>
      '''Runs the given script. This command is provided for the sake of symmetry. 
   The recommended method is to use the simplier form ${Settings().appname} <script path.dart>''';

  // CommandRun.fromScriptArg(String argument) {
  //   Script.validate(argument);
  //   Script script = Script.fromArg(selectedFlags.values.toList(), argument);
  //   script.run(selectedFlags, subarguments);
  // }

  @override
  List<String> completion(String word) {
    return completionExpandScripts(word);
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
