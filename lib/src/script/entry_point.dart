import 'dart:cli';
import 'dart:io';

import 'package:dshell/dshell.dart';

import 'commands/help.dart';
import '../util/ansi_color.dart';
import '../util/stack_trace_impl.dart';

import 'command_line_runner.dart';
import 'commands/commands.dart';
import 'std_log.dart';

class EntryPoint {
  static EntryPoint _self;

  factory EntryPoint() {
    _self ??= EntryPoint._internal();
    return _self;
  }

  EntryPoint._internal() {
    _self = this;
  }

  static void init() {
    EntryPoint._internal();
  }

  int process(List<String> arguments) {
    return _parseCmdLine(arguments, Commands.applicationCommands);
  }

  int _parseCmdLine(List<String> arguments, List<Command> availableCommands) {
    try {
      CommandLineRunner.init(availableCommands);
      exitCode = CommandLineRunner().process(arguments);

      StdLog.stderr('Exiting with code $exitCode', LogLevel.verbose);

      waitFor<void>(stderr.flush());

      return exitCode;
    } on CommandLineException catch (e) {
      StdLog.stderr(red(e.toString()));
      print('');
      HelpCommand().printUsageHowTo();
      return 1;
    } catch (e, stackTrace) {
      var impl = StackTraceImpl.fromStackTrace(stackTrace);
      StdLog.stderr('Exception occured: ${e} of type ${e.runtimeType}');
      StdLog.stderr('Stacktrace: ${impl.formatStackTrace()}');
    }

    return 0;
  }
}
