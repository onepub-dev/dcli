import '../util/dshell_exception.dart';

import '../settings.dart';
import 'commands/commands.dart';
import 'commands/run.dart';
import 'flags.dart';

class CommandLineRunner {
  static CommandLineRunner _self;

  static List<Flag> availableFlags = [VerboseFlag()];

  // Tracks the set of flags the users set on the command line.
  Flags flagsSet = Flags();
  Map<String, Command> availableCommands;

  factory CommandLineRunner() {
    if (_self == null) {
      throw Exception('The CommandLineRunner has not been intialised');
    }
    return _self;
  }

  static void init(List<Command> availableCommands) {
    _self = CommandLineRunner.internal(Commands.asMap(availableCommands));
  }

  CommandLineRunner.internal(this.availableCommands);

  int process(List<String> arguments) {
    int exitCode;

    var success = false;

    // Find the command and run it.
    Command command;
    var cmdArguments = <String>[];

    for (var i = 0; i < arguments.length; i++) {
      final argument = arguments[i];

      if (Flags.isFlag(argument)) {
        var flag = flagsSet.findFlag(argument, availableFlags);

        if (flag != null) {
          if (flagsSet.isSet(flag)) {
            throw DuplicateOptionsException(argument);
          }
          flagsSet.set(flag);
          Settings().verbose('Setting flag: ${flag.name}');
          if (flag == VerboseFlag()) {
            Settings().verbose('DShell Version: ${Settings().version}');
          }
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
        Settings().verbose('Found command $command');
        success = true;
        break;
      }

      // its not a flag, its not a command, so it must be a script.
      command = RunCommand();
      Settings().verbose('Found Script $argument');
      cmdArguments = arguments.sublist(i);
      success = true;
      break;
    }

    if (success) {
      // get the script name and remaning args as they are the arguments for the command to process.
      exitCode = command.run(Settings().selectedFlags, cmdArguments);
    } else {
      throw InvalidArguments('Invalid arguments passed.');
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
  @override
  String toString() => message;
}

class UnknownOption extends OptionsException {
  final String optionName;

  UnknownOption(this.optionName) : super('The option $optionName is unknown!');

  @override
  String toString() => message;
}

class InvalidScript extends CommandLineException {
  InvalidScript(String message) : super(message);
}

class UnknownCommand extends CommandLineException {
  final String command;

  UnknownCommand(this.command)
      : super(
            'The command ${command} was not recognised. Scripts must end with .dart!');
}

class UnknownFlag extends CommandLineException {
  final String flag;

  UnknownFlag(this.flag) : super('The flag ${flag} was not recognised!');

  @override
  String toString() => message;
}

class InvalidArguments extends CommandLineException {
  InvalidArguments(String message) : super(message);
}
