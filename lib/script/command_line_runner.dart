import 'args.dart';
import 'commands/commands.dart';
import 'commands/run.dart';
import 'flags.dart';

class CommandLineRunner {
  String appname;
  List<Flag> availableFlags;
  Map<String, Command> availableCommands;

  // the list of flags selected via the cli.
  Map<String, Flag> selectedFlags = Map();

  CommandLineRunner(
      this.appname, this.availableFlags, List<Command> availableCommands)
      : this.availableCommands = buildCommandMap(availableCommands);

  int process(List<String> arguments) {
    int exitCode;

    bool success = false;

    // Find the command and run it.
    Command command;
    List<String> subarguments = List();

    int i = 0;
    for (; i < arguments.length; i++) {
      final String argument = arguments[i];

      if (Flags.isFlag(argument)) {
        Flag flag = Flags.findFlag(argument, availableFlags);

        if (flag != null) {
          if (selectedFlags.containsKey(flag.name)) {
            throw DuplicateOptionsException(argument);
          }
          selectedFlags[flag.name] = flag;
          continue;
        } else {
          throw UnknownFlag(argument);
        }
      }

      // there may only be one command on the cli.
      command = Commands.findCommand(argument, availableCommands);
      if (command != null) {
        success = true;
        break;
      }

      // its not a flag, its not a command, so it must be a script.
      command = RunCommand();
      success = true;
      break;
    }

    if (success) {
      // get the remaning args as the are arguments for the command to process.
      if (i + 1 < arguments.length) {
        subarguments = arguments.sublist(i + 1);
      }

      exitCode = command.run(selectedFlags.values.toList(), subarguments);
    } else {
      usage();

      throw InvalidArguments("Invalid arguments passed.");
    }
    return exitCode;
  }

  void usage() {}

  static Map<String, Command> buildCommandMap(List<Command> availableCommands) {
    Map<String, Command> mapCommands = Map();
    availableCommands.forEach((command) => mapCommands[command.name] = command);

    return mapCommands;
  }
}
