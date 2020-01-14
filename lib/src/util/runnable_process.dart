import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dshell/src/util/stack_trace_impl.dart';

import 'waitForEx.dart';
import '../../dshell.dart';
import 'dshell_exception.dart';
import 'log.dart';

typedef LineAction = void Function(String line);
typedef CancelableLineAction = bool Function(String line);

/// [printerr] provides the equivalent functionality to the
/// standard Dart print function but instead writes
/// the output to stderr rather than stdout.
///
/// CLI applications should, by convention, write error messages
/// out to stderr and expected output to stdout.
///
/// [line] the line to write to stderr.
void printerr(String line) => stderr.write(line);

class RunnableProcess {
  Future<Process> fProcess;

  final String workingDirectory;

  ParsedCliCommand parsed;

  RunnableProcess(String cmdLine, {this.workingDirectory})
      : parsed = ParsedCliCommand(cmdLine);

  RunnableProcess.fromList(String command, List<String> args,
      {this.workingDirectory})
      : parsed = ParsedCliCommand.fromParsed(command, args);

  String get cmdLine => parsed.cmd + ' ' + parsed.args.join(' ');

  /// Experiemental - DO NOT USE
  Stream<List<int>> get stream {
    // wait until the process has started
    var process = waitForEx<Process>(fProcess);
    return process.stdout;
  }

  /// Experiemental - DO NOT USE
  Sink<List<int>> get sink {
    // wait until the process has started
    var process = waitForEx<Process>(fProcess);
    return process.stdin;
  }

  void start({bool runInShell = false, bool detached = false}) {
    var workdir = workingDirectory;
    workdir ??= Directory.current.path;

    var mode = detached ? ProcessStartMode.detached : ProcessStartMode.normal;

    fProcess = Process.start(
      parsed.cmd,
      parsed.args,
      runInShell: runInShell,
      workingDirectory: workdir,
      mode: mode,
    );
  }

  void pipeTo(RunnableProcess stdin) {
    fProcess.then((stdoutProcess) {
      stdin.fProcess.then<void>(
          (stdInProcess) => stdoutProcess.stdout.pipe(stdInProcess.stdin));
    });
  }

  // Monitors the process until it exists.
  // If a LineAction exists we call
  // line action each time the process emmits a line.
  void processUntilExit(LineAction stdoutAction, [LineAction stderrAction]) {
    var done = Completer<bool>();

    fProcess.then((process) {
      /// handle stdout stream
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (stdoutAction != null) {
          stdoutAction(line);
        }
      });

      // handle stderr stream
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (stderrAction != null) {
          stderrAction(line);
        } else {
          print(line);
        }
      });
      // trap the process finishing
      process.exitCode.then((exitCode) {
        // TODO: do we pass the exitCode to ForEach or just throw?
        if (exitCode != 0) {
          done.completeError(RunException(exitCode,
              'The command [$cmdLine] failed with exitCode: ${exitCode}'));
        } else {
          done.complete(true);
        }
      });
    });
    waitForEx<bool>(done.future);
  }
}

/// Class to parse a OS command, contained in a string, which we need to pass
/// into the dart Process.start method as a application name and a series
/// of arguments.
class ParsedCliCommand {
  String cmd;
  List<String> args;

  ParsedCliCommand(String command) {
    parse(command);
  }

  ParsedCliCommand.fromParsed(this.cmd, this.args);

  void parse(String command) {
    // TODO: improve parser so it can handle quoted strings.
    // we shouldn't replace a double space if it is within a quoted string.
    command = command.replaceAll('  ', ' ');
    var parts = command.split(' ');

    cmd = parts[0];
    args = [];

    if (parts.length > 1) {
      args = parts.sublist(1);
    }

    if (Settings().debug_on) {
      Log.d('${Directory.current}');
      Log.d('cmd: $cmd args: $args');
    }
  }
}

class RunException extends DShellException {
  int exitCode;
  String reason;
  RunException(this.exitCode, this.reason, {StackTraceImpl stackTrace})
      : super(reason, stackTrace);

  @override
  RunException copyWith(StackTraceImpl stackTrace) {
    return RunException(exitCode, reason, stackTrace: stackTrace);
  }
}
