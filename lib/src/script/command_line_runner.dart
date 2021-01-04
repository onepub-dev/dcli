import '../settings.dart';
import '../util/dcli_exception.dart';

import 'commands/commands.dart';
import 'commands/run.dart';
import 'flags.dart';

/// Runs a dcli script.
class CommandLineRunner {
  static CommandLineRunner? _self;

  /// the list of flags set on the command line.
  static List<Flag> globalFlags = [VerboseFlag()];

  // Tracks the set of flags the users set on the command line.
  final Flags _flagsSet = Flags();
  Map<String, Command> _availableCommands;

  ///
  factory CommandLineRunner() {
    if (_self == null) {
      throw Exception('The CommandLineRunner has not been intialised');
    }
    return _self!;
  }

  /// initialises the [CommandLineRunner]
  static void init(List<Command> availableCommands) {
    _self = CommandLineRunner._internal(Commands.asMap(availableCommands));
  }

  CommandLineRunner._internal(this._availableCommands);

  /// Process the command line arguments to run the command.
  int? process(List<String> arguments) {
    int? exitCode;

    var success = false;

    // Find the command and run it.
    Command? command;
    var cmdArguments = <String>[];

    for (var i = 0; i < arguments.length; i++) {
      final argument = arguments[i];

      if (Flags.isFlag(argument)) {
        final flag = _flagsSet.findFlag(argument, globalFlags);

        if (flag != null) {
          if (_flagsSet.isSet(flag)) {
            throw DuplicateOptionsException(argument);
          }
          _flagsSet.set(flag);
          Settings().verbose('Setting flag: ${flag.name}');
          if (flag == VerboseFlag()) {
            Settings().verbose('DCli Version: ${Settings().version}');
          }
          continue;
        } else {
          throw UnknownFlag(argument);
        }
      }

      // there may only be one command on the cli.
      command = Commands.findCommand(argument, _availableCommands);
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
      exitCode = command!.run(Settings().selectedFlags, cmdArguments);
    } else {
      throw InvalidArguments('Invalid arguments passed.');
    }
    return exitCode;
  }
}

/// Don't use this exception directly (its abstract).
/// Instead use one of the more specific derived exceptions or create
/// your own extending from this exception.
abstract class CommandLineException extends DCliException {
  ///
  CommandLineException(String message) : super(message);
}

/// Thrown when an invalid command line option is passed.
class OptionsException extends CommandLineException {
  ///
  OptionsException(String message) : super(message);
}

/// Thrown when an duplicate command line option is passed.
class DuplicateOptionsException extends OptionsException {
  /// Thrown when an invalid command line option is passed.
  DuplicateOptionsException(String optionName)
      : super('Option $optionName used twice!');
  @override
  String toString() => message;
}

/// Thrown when an unknown command line option is passed.
class UnknownOption extends OptionsException {
  ///
  UnknownOption(String optionName)
      : super('The option $optionName is unknown!');

  @override
  String toString() => message;
}

/// Thrown when an invalid script name is passed to the  command line.
class InvalidScript extends CommandLineException {
  /// Thrown when an invalid script name is passed to the  command line.
  InvalidScript(String message) : super(message);
}

/// Thrown when an invalid command  is passed.
class UnknownCommand extends CommandLineException {
  ///
  UnknownCommand(String command)
      : super(
            'The command $command was not recognised. Scripts must end with .dart!');
}

/// Thrown when an unknown flag is passed to a command.
class UnknownFlag extends CommandLineException {
  ///
  UnknownFlag(String flag) : super('The flag $flag was not recognised!');

  @override
  String toString() => message;
}

/// Thrown when an invalid argument is passed to a command.
class InvalidArguments extends CommandLineException {
  ///
  InvalidArguments(String message) : super(message);
}
