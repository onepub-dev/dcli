import 'dart:async';
import 'dart:cli';
import 'dart:convert';
import 'dart:io';

import 'package:dshell/util/log.dart';
import 'package:dshell/util/stack_trace_impl.dart';

import 'command.dart';
import 'settings.dart';

///
/// Runs the given cli command calling [lineAction]
/// for each line the cli command returns.
/// [lineAction] is called as the command runs rather than waiting
/// for the command to complete.
///
/// The run function is syncronous and a such will not return
/// until the command completes.
///
/// If the command fails or returns a non-zero exitCode
/// Then a [RunCommand] exception will be thrown.
///
Process run(String command, [LineAction lineAction]) =>
    Run().run(command, lineAction);

typedef void LineAction(String line);

class Run extends Command {
  ParsedCliCommand parsed;

  Process run(String command, [LineAction lineAction]) {
    StreamController<String> _controller = StreamController<String>();

    parsed = ParsedCliCommand(command);

    Completer<bool> done = Completer<bool>();
    Process self = waitFor<Process>(
        Process.start(parsed.cmd, parsed.args, runInShell: false)
            .then((Process process) {
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (lineAction != null) {
          lineAction(line);
        }
        _controller.add(line);
      });

      // trap the process finishing
      process.exitCode.then((exitCode) {
        if (exitCode != 0) {
          done.completeError(RunException(
              "The command [${this.runtimeType}] failed with exitCode: ${exitCode}"));
        } else {
          done.complete(true);
        }
      });

      return process;
    }));

    smartWaitFor<bool>(done.future);

    return self;
  }

  static Future<Process> start(String command) {
    ParsedCliCommand parsed = ParsedCliCommand(command);
    Future<Process> process =
        Process.start(parsed.cmd, parsed.args, runInShell: false);

    return process;
  }

  /// Wraps the standard cli waitFor
  /// but rethrows any exceptions with
  /// a stack that is cohernt.
  /// Exceptions would normally have a microtask
  /// stack which is useless.
  /// This version replaces the exceptions stack
  /// with a full stack.
  static T smartWaitFor<T>(Future<T> future) {
    RunException exception;
    T value;
    try {
      value = waitFor<T>(future);
    } on AsyncError catch (e) {
      if (e.error is RunException) {
        exception = e.error as RunException;
      } else {
        rethrow;
      }
    }

    if (exception != null) {
      // recreate the exception so we have a full
      // stacktrace rather than the microtask
      // stacktrace the future leaves us with.
      StackTraceImpl stackTrace = StackTraceImpl(skipFrames: 2);

      throw RunException.rebuild(exception, stackTrace);
    }
    return value;
  }
}

class ParsedCliCommand {
  String cmd;
  List<String> args;

  ParsedCliCommand(String command) {
    parse(command);
  }

  void parse(String command) {
    List<String> parts = command.split(" ");

    cmd = parts[0];
    args = List();

    if (parts.length > 1) {
      args = parts.sublist(1);
    }

    if (Settings().debug_on) {
      Log.d("${Directory.current}");
      Log.d("cmd $cmd args: $args");
    }
  }
}

class RunException extends CommandException {
  RunException(String reason) : super(reason);

  RunException.rebuild(RunException e, StackTraceImpl stackTrace)
      : super.rebuild(e, stackTrace);
}
