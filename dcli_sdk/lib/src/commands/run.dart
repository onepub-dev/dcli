/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';

import '../script/flag.dart';
import '../util/completion.dart';
import '../util/exceptions.dart';
import '../util/exit.dart';
import 'commands.dart';

/// Runs a dart script.
class RunCommand extends Command {
  static const _commandName = 'run';

  ///
  RunCommand() : super(_commandName);

  ///
  ///
  /// [arguments] - the arguments passed directly to the run command.
  /// Returns the called processes exitcode;
  /// @Throwing(InvalidCommandArgumentException)
  /// @Throwing(InvalidScript)
  /// @Throwing(RunException)
  @override
  Future<int> run(List<Flag> selectedFlags, List<String> arguments) async {
    if (arguments.isEmpty) {
      throw InvalidCommandArgumentException(
        'Expected a script or command. No arguments were found.',
      );
    }
    final scriptPath = arguments[0];
    validateScriptPath(scriptPath);

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
        dcliExit(1);
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
   The recommended method is to use the simplier form ${Settings.dcliAppName} <script path.dart>''';

  @override
  List<String> completion(String word) => completionExpandScripts(word);

  @override
  List<Flag> flags() => [];

  /// validate that the passed arguments points to a valid script
  /// @Throwing(InvalidCommandArgumentException)
  /// @Throwing(InvalidScript)
  static void validateScriptPath(String scriptPath) {
    if (!scriptPath.endsWith('.dart')) {
      throw InvalidCommandArgumentException(
        'Expected a script name (ending in .dart) '
        'instead found: $scriptPath',
      );
    }

    if (!exists(scriptPath)) {
      throw InvalidScript('The script ${truepath(scriptPath)} does not exist.');
    }
    if (!isFile(scriptPath)) {
      throw InvalidScript('The script ${truepath(scriptPath)} is not a file.');
    }
  }
}
