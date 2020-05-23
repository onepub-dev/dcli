import 'dart:cli';
import 'dart:io';

import '../../dshell.dart';

import '../util/ansi_color.dart';
import '../util/stack_trace_impl.dart';

import 'command_line_runner.dart';
import 'commands/commands.dart';
import 'commands/help.dart';

/// the 'main' for running commands.
class EntryPoint {
  static EntryPoint _self;

  ///
  factory EntryPoint() {
    _self ??= EntryPoint._internal();
    return _self;
  }

  EntryPoint._internal() {
    _self = this;
  }

  ///
  static void init() {
    EntryPoint._internal();
  }

  /// process the command line
  int process(List<String> arguments) {
    return _parseCmdLine(arguments, Commands.applicationCommands);
  }

  int _parseCmdLine(List<String> arguments, List<Command> availableCommands) {
    try {
      CommandLineRunner.init(availableCommands);
      exitCode = CommandLineRunner().process(arguments);

      Settings().verbose('Exiting with code $exitCode');

      waitFor<void>(stderr.flush());

      return exitCode;
    } on CommandLineException catch (e) {
      printerr(red(e.toString()));
      print('');
      HelpCommand.printUsageHowTo();
      return 1;
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e, stackTrace) {
      var impl = StackTraceImpl.fromStackTrace(stackTrace);
      printerr('Exception occured: $e of type ${e.runtimeType}');
      printerr('Stacktrace: ${impl.formatStackTrace()}');
      return 1;
    }
  }
}
