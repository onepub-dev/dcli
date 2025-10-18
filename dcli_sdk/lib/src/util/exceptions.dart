import 'package:dcli_core/dcli_core.dart';

/// Don't use this exception directly (its abstract).
/// Instead use one of the more specific derived exceptions or create
/// your own extending from this exception.
abstract class CommandLineException extends DCliException {
  ///
  CommandLineException(super.message);
}

/// Thrown when an invalid argument is passed to a command.
class InvalidCommandArgumentException extends CommandLineException {
  ///
  InvalidCommandArgumentException(super.message);
}

/// Thrown when an invalid command line option is passed.
class OptionsException extends CommandLineException {
  ///
  OptionsException(super.message);
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
  InvalidScript(super.message);
}

/// Thrown when an invalid command  is passed.
class UnknownCommand extends CommandLineException {
  ///
  UnknownCommand(String command)
      : super(
          'The command $command was not recognised. '
          'Scripts must end with .dart!',
        );
}

/// Thrown when an unknown flag is passed to a command.
class UnknownFlag extends CommandLineException {
  ///
  UnknownFlag(String flag) : super('The flag $flag was not recognised!');

  @override
  String toString() => message;
}

/// throw if we found an invalid flag.
class InvalidFlagOptionException extends CommandLineException {
  ///
  InvalidFlagOptionException(super.message);
}

class DCliNotInstalledException extends CommandLineException {
  ///
  DCliNotInstalledException(super.message);
}

class ExitWithMessageException extends DCliException {
  ///
  ExitWithMessageException(super.message);
}
