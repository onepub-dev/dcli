import 'package:dshell/script/commands/clean.dart';
import 'package:dshell/script/commands/clean_all.dart';
import 'package:dshell/script/commands/compile.dart';
import 'package:dshell/script/commands/create.dart';
import 'package:dshell/script/commands/merge.dart';
import 'package:dshell/script/commands/run.dart';
import 'package:dshell/script/commands/split.dart';

import '../flags.dart';
import 'help.dart';

class Commands {
  static List<Command> get applicationCommands => [
        CleanAllCommand(),
        CleanCommand(),
        CompileCommand(),
        CreateCommand(),
        MergeCommand(),
        RunCommand(),
        SplitCommand(),
        HelpCommand()
      ];

  static Command findCommand(String argument, Map<String, Command> commands) {
    Command command = commands[argument.toLowerCase()];

    return command;
  }

  static Map<String, Command> asMap(List<Command> availableCommands) {
    Map<String, Command> mapCommands = Map();
    availableCommands.forEach((command) => mapCommands[command.name] = command);

    return mapCommands;
  }
}

abstract class Command {
  String _name;

  Command(this._name);

  // Returns the exitCode of the script that is run
  // If a script isn't run then return 0 for success
  // or thrown an exception on any error.
  int run(List<Flag> selectedFlags, List<String> subarguments);

  String get name => _name;

  String usage();

  String description();
}
