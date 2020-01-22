import 'package:dshell/src/script/commands/version.dart';

import 'clean.dart';
import 'clean_all.dart';
import 'compile.dart';
import 'create.dart';
import 'doctor.dart';
import 'merge.dart';
import 'run.dart';
import 'split.dart';

import '../flags.dart';
import 'help.dart';
import 'install.dart';

class Commands {
  static List<Command> get applicationCommands => [
        CleanAllCommand(),
        CleanCommand(),
        CompileCommand(),
        CreateCommand(),
        DoctorCommand(),
        InstallCommand(),
        MergeCommand(),
        RunCommand(),
        SplitCommand(),
        VersionCommand(),
        HelpCommand(),
      ];

  static Command findCommand(String argument, Map<String, Command> commands) {
    var command = commands[argument.toLowerCase()];

    return command;
  }

  static Map<String, Command> asMap(List<Command> availableCommands) {
    var mapCommands = <String, Command>{};
    availableCommands.forEach((command) => mapCommands[command.name] = command);

    return mapCommands;
  }
}

abstract class Command {
  final String _name;

  Command(this._name);

  // Returns the exitCode of the script that is run
  // If a script isn't run then return 0 for success
  // or thrown an exception on any error.
  int run(List<Flag> selectedFlags, List<String> subarguments);

  String get name => _name;

  /// returns a single line  high level desription of how to use the command
  /// e.g.
  ///  compile [--noclean] [--install] [--overwrite] <script path.dart>
  String usage();

  ///
  /// returns detailed description of what the command does
  /// which may be formatted across multiple lines.
  /// Each line of the text should be indented by four spaces.
  String description();

  /// Returns the list of flags supported by this command
  List<Flag> flags();

  /// Used by the dshell_completion app to
  /// provide command line completion to bash
  /// Each command should return of list of arguments
  /// suitable for the command.
  /// e.g. dshell clean <word> should return
  /// a list of dshell scripts in the current directory
  /// that match the word prefix.
  List<String> completion(String word);
}
