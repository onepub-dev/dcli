import 'dart:cli';
import 'dart:io';

import 'package:dshell/script/flags.dart';
import 'package:dshell/util/stack_trace_impl.dart';

import 'command_line_runner.dart';
import 'commands/commands.dart';
import 'std_log.dart';

import 'package:dshell/script/pub_get.dart';

class EntryPoint {
  static EntryPoint _self = EntryPoint._internal();

  factory EntryPoint() {
    return _self;
  }

  EntryPoint._internal() {
    _self = this;
  }

  int process(List<String> arguments) {
    return parseCmdLine(
        arguments, Flags.applicationFlags, Commands.applicationCommands);
  }

  int parseCmdLine(List<String> arguments, List<Flag> availableFlags,
      List<Command> availableCommands) {
    try {
      CommandLineRunner.init(availableFlags, availableCommands);
      exitCode = CommandLineRunner().process(arguments);

      StdLog.stderr('Exiting with code $exitCode', LogLevel.verbose);

      waitFor<void>(stderr.flush());

      return exitCode;
    } on CommandLineException catch (e) {
      StdLog.stderr(e.toString());
      return 1;
    } on PubGetException catch (e) {
      StdLog.stderr(' Running "pub get" failed with exit code ${e.exitCode}!');
      return 1;
    } catch (e, stackTrace) {
      StackTraceImpl impl = StackTraceImpl.fromStackTrace(stackTrace);
      StdLog.stderr('Exception occured: ${e}');
      StdLog.stderr('Stacktrace: ${impl.formatStackTrace()}');
    }

    return 0;
  }
}
