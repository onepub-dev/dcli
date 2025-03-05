/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import '../script/flags.dart';
import 'clean.dart';
import 'compile.dart';
import 'create.dart';
import 'doctor.dart';
import 'help.dart';
import 'install.dart';
import 'lock.dart';
import 'pack.dart';
import 'run.dart';
import 'upgrade.dart';
import 'version.dart';
import 'warmup.dart';

//// List of supported commands.
class Commands {
  /// List of supported comands
  static List<Command> get applicationCommands => [
        CleanCommand(),
        CompileCommand(),
        CreateCommand(),
        DoctorCommand(),
        InstallCommand(),
        LockCommand(),
        PackCommand(),
        RunCommand(),
        UpgradeCommand(),
        VersionCommand(),
        WarmupCommand(),
        HelpCommand(),
      ];

  /// Find the command based on the [argument] passed
  static Command? findCommand(String argument, Map<String, Command> commands) {
    final command = commands[argument.toLowerCase()];

    return command;
  }

  /// returns map of supprted commands where the command name is the key.
  static Map<String, Command> asMap(List<Command> availableCommands) {
    final mapCommands = <String, Command>{};
    for (final command in availableCommands) {
      mapCommands[command.name] = command;
    }

    return mapCommands;
  }
}

/// base class for all commands.
abstract class Command {
  ///
  Command(this._name);

  final String _name;

  /// Returns the exitCode of the script that is run
  /// If a script isn't run then return 0 for success
  /// or thrown an exception on any error.
  Future<int> run(List<Flag> selectedFlags, List<String> subarguments);

  /// name of the command
  String get name => _name;

  /// returns a single line  high level desription of how to use the command
  /// e.g.
  ///  compile [--nowarmup] [--install] [--overwrite] <script path.dart>
  String usage();

  ///
  /// returns detailed description of what the command does
  /// which may be formatted across multiple lines.
  /// Each line of the text should be indented by four spaces.
  String description({bool extended});

  /// Returns the list of flags supported by this command
  List<Flag> flags();

  /// Used by the dcli_completion app to
  /// provide command line completion to bash
  /// Each command should return of list of arguments
  /// suitable for the command.
  /// e.g. dcli warmup `<word>` should return
  /// a list of dcli scripts in the current directory
  /// that match the word prefix.
  List<String> completion(String word);
}
