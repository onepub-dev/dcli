import 'package:dshell/script/commands/help.dart';
import 'package:dshell/util/dshell_exception.dart';

import '../settings.dart';
import 'commands/commands.dart';
import 'commands/run.dart';
import 'flags.dart';

class CommandLineRunner {
  static CommandLineRunner _self;

  List<Flag> availableFlags;
  Map<String, Command> availableCommands;

  factory CommandLineRunner() {
    if (_self == null) {
      throw Exception("The CommandLineRunner has not been intialised");
    }
    return _self;
  }

  static void init(List<Flag> availableFlags, List<Command> availableCommands) {
    _self = CommandLineRunner.internal(
        availableFlags, Commands.asMap(availableCommands));
  }

  CommandLineRunner.internal(this.availableFlags, this.availableCommands);

  int process(List<String> arguments) {
    int exitCode;

    bool success = false;

    // Find the command and run it.
    Command command;
    List<String> cmdArguments = List();

    int i = 0;
    for (; i < arguments.length; i++) {
      final String argument = arguments[i];

      if (Flags.isFlag(argument)) {
        Flag flag = Flags.findFlag(argument, availableFlags);

        if (flag != null) {
          if (Flags.isSet(flag)) {
            throw DuplicateOptionsException(argument);
          }
          Flags.set(flag);
          continue;
        } else {
          throw UnknownFlag(argument);
        }
      }

      // there may only be one command on the cli.
      command = Commands.findCommand(argument, availableCommands);
      if (command != null) {
        if (i + 1 < arguments.length) {
          cmdArguments = arguments.sublist(i + 1);
        }
        success = true;
        break;
      }

      // its not a flag, its not a command, so it must be a script.
      command = RunCommand();
      cmdArguments = arguments.sublist(i);
      success = true;
      break;
    }

    if (success) {
      // get the script name and remaning args as they are the arguments for the command to process.
      exitCode = command.run(Settings().selectedFlags, cmdArguments);
    } else {
      throw InvalidArguments("Invalid arguments passed.");
    }
    return exitCode;
  }
}

class CommandLineException extends DShellException {
  CommandLineException(String message) : super(message);
}

class OptionsException extends CommandLineException {
  OptionsException(String message) : super(message);
}

class DuplicateOptionsException extends OptionsException {
  final String optionName;

  DuplicateOptionsException(this.optionName)
      : super('Option ${optionName} used twice!');
  String toString() => message;
}

class UnknownOption extends OptionsException {
  final String optionName;

  UnknownOption(this.optionName) : super('The option $optionName is unknown!');

  String toString() => message;
}

class InvalidScript extends CommandLineException {
  InvalidScript(String message) : super(message);
}

class UnknownCommand extends CommandLineException {
  final String command;

  UnknownCommand(this.command)
      : super(
            "The command ${command} was not recognised. Scripts must end with .dart!");
}

class UnknownFlag extends CommandLineException {
  final String flag;

  UnknownFlag(this.flag) : super("The flag ${flag} was not recognised!");

  String toString() => message;
}

class InvalidArguments extends CommandLineException {
  InvalidArguments(String message) : super(message);
}
