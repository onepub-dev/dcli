import 'dart:io';

import '../../../dcli.dart';
import '../../util/completion.dart';
import '../command_line_runner.dart';
import '../flags.dart';
import 'commands.dart';

/// Runs a dart script.
class RunCommand extends Command {
  ///
  RunCommand() : super(_commandName);

  static const String _commandName = 'run';

  ///
  ///
  /// [arguments] - the arguments passed directly to the run command.
  /// Returns the called processes exitcode;
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.isEmpty) {
      throw InvalidArgumentsException(
        'Expected a script or command. No arguments were found.',
      );
    }
    final scriptPath = arguments[0];
    DartScript.validate(scriptPath);

    final script = DartScript.fromFile(scriptPath);

    if (Shell.current.isSudo) {
      /// we are running sudo, so we can't init a script
      /// as we will end up with root permissions everywhere.
      if (!script.isReadyToRun) {
        printerr(
          red(
            'The script is not ready to run, so cannot be run from sudo. '
            'Run dcli warmup $scriptPath',
          ),
        );
        exit(1);
      }
    }

    verbose(() => 'Running script ${script.pathToScript}');

    var scriptArguments = <String>[];

    if (arguments.length > 1) {
      scriptArguments = arguments.sublist(1);
    }

    verbose(() => 'Script Arguments: ${scriptArguments.join(", ")}');

    final exitCode = script.run(args: scriptArguments);

    return exitCode;
  }

  @override
  String usage() => 'run <script path.dart>';

  @override
  String description({bool extended = false}) => '''
Runs the given script. This command is provided for the sake of symmetry. 
   The recommended method is to use the simplier form ${Settings().appname} <script path.dart>''';

  // CommandRun.fromScriptArg(String argument) {
  //   Script.validate(argument);
  //   Script script = Script.fromArg(selectedFlags.values.toList(), argument);
  //   script.run(selectedFlags, subarguments);
  // }

  @override
  List<String> completion(String word) => completionExpandScripts(word);

  @override
  List<Flag> flags() => [];
}
