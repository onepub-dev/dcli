import 'dart:collection';

import 'dart:io';

import 'script.dart';

typedef void ScriptExecutor(String scriptpath, List<String> arguments);

/// A singleton factory
///
/// At startup call
///
/// Args.parse.
///
/// Then call Args() an any point to get access to the current args.
///
class Args {
  static Args _self;

  // The name of the running app (e.g. dscript)
  // used in logging errors.
  final String appname;

  // The current working directory where the user
  // launched the script from.
  // This may not be the same as the script directory.
  final String workingDirectory;

  final Script script;

  /// The original command line Arguments
  final UnmodifiableListView<String> arguments;

  /// Execute in verbose mode
  bool verbose;

  // if true then we clean out the project cache
  // before running the script.
  // This will force a rebuild of the project cache
  // and a calll to pub get.
  final bool cleanProject;

  bool get isVerbose => verbose;

  Map<String, bool> isRedundant = Map();

  Args._internal(this.appname, String scriptArg, this.arguments,
      {this.verbose = false, this.cleanProject = false})
      : workingDirectory = Directory.current.path,
        script = Script.fromArg([], scriptArg) {
    _self = this;
  }

  factory Args() {
    assert(_self != null);
    return _self;
  }
}

class ArgsException implements Exception {
  String toString();
}

class OptionsException implements ArgsException {}

class DuplicateOptionsException extends OptionsException {
  final String optionName;

  String message;
  DuplicateOptionsException(this.optionName)
      : message = 'Option ${optionName} used twice!';
  String toString() => message;
}

class UnknownOption implements OptionsException {
  final String optionName;
  String message;

  UnknownOption(this.optionName)
      : message = 'The option $optionName is unknown!';

  String toString() => message;
}

class InvalidScript implements ArgsException {
  String message;

  InvalidScript(String message);

  String toString() => message;
}

class UnknownCommand implements ArgsException {
  final String command;
  String message;

  UnknownCommand(this.command)
      : message =
            "The command ${command} was not recognised. Scripts must end with .dart!";

  String toString() => message;
}

class UnknownFlag implements ArgsException {
  final String flag;
  String message;

  UnknownFlag(this.flag) : message = "The flag ${flag} was not recognised!";

  String toString() => message;
}

class InvalidArguments implements ArgsException {
  String message;
  InvalidArguments(this.message);

  String toString() => message;
}
