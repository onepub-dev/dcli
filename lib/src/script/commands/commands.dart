import 'clean.dart';
import 'clean_all.dart';
import 'compile.dart';
import 'create.dart';
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
        InstallCommand(),
        MergeCommand(),
        RunCommand(),
        SplitCommand(),
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

  String usage();

  String description();
}
