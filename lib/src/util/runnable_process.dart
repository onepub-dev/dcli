import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dshell/src/functions/env.dart';
import 'package:dshell/src/util/parse_cli_command.dart';
import 'package:dshell/src/util/stack_trace_impl.dart';
import 'package:meta/meta.dart';

import 'progress.dart';
import 'waitForEx.dart';
import '../../dshell.dart';
import 'dshell_exception.dart';

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
void printerr(String line) {
  stderr.writeln(line);
  // waitForEx<dynamic>(stderr.flush());
}

class RunnableProcess {
  Future<Process> fProcess;

  final String workingDirectory;

  ParsedCliCommand parsed;

  /// Spawns a process to run the command contained in [cmdLine] along with
  /// the args passed via the [cmdLine].
  ///
  /// Glob expansion is performed on each non-quoted argument.
  ///
  RunnableProcess.fromCommandLine(String cmdLine, {this.workingDirectory})
      : parsed = ParsedCliCommand(cmdLine, workingDirectory);

  /// Spawns a process to run the command contained in [command] along with
  /// the args passed via the [args].
  ///
  /// Glob expansion is performed on each non-quoted argument.
  ///
  RunnableProcess.fromCommandArgs(String command, List<String> args,
      {this.workingDirectory})
      : parsed = ParsedCliCommand.fromParsed(command, args, workingDirectory);

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

  void start({
    bool runInShell = false,
    bool detached = false,
    bool waitForStart = true,
    bool terminal = false,
  }) {
    var workdir = workingDirectory;
    workdir ??= Directory.current.path;

    assert(!(terminal == true && detached == true),
        'You cannot enable terminal and detached at the same time');

    var mode = detached ? ProcessStartMode.detached : ProcessStartMode.normal;
    if (terminal) {
      mode = ProcessStartMode.inheritStdio;
    }

    if (Settings().isVerbose) {
      Settings().verbose(
          'Starting(runInShell: $runInShell workingDir: $workingDirectory mode: $mode)');
      Settings().verbose('CommandLine: ${parsed.cmd} ${parsed.args.join(' ')}');
    }

    fProcess = Process.start(
      parsed.cmd,
      parsed.args,
      runInShell: runInShell,
      workingDirectory: workdir,
      mode: mode,
      environment: envs,
    );

    // we wait for the process to start.
    // if the start fails we get a clean exception
    // by waiting here.
    if (waitForStart) {
      _waitForStart();
    }
  }

  void _waitForStart() {
    var complete = Completer<Process>();

    fProcess.then((process) {
      complete.complete(process);
    }).catchError((Object e, StackTrace s) {
      // 2 - No such file or directory
      if (e is ProcessException && e.errorCode == 2) {
        var ep = e as ProcessException;
        e = ProcessException(
          ep.executable,
          ep.arguments,
          'Could not find ${ep.executable} on the path.',
          ep.errorCode,
        );
      }
      complete.completeError(e);
    });
    waitForEx<Process>(complete.future);
  }

  /// Waits for the process to exit
  /// We use this method when we can't or don't
  /// want to process IO.
  /// The main use is when using start(terminal:true).
  /// We don't have access to any IO so we just
  /// have to wait for things to finish.
  int waitForExit() {
    var exited = Completer<int>();
    fProcess.then((process) {
      var exitCode = waitForEx<int>(process.exitCode);

      if (exitCode != 0) {
        exited.completeError(RunException(exitCode,
            'The command ${red('[$cmdLine]')} failed with exitCode: ${exitCode}'));
      } else {
        exited.complete(exitCode);
      }
    });
    return waitForEx<int>(exited.future);
  }

  void pipeTo(RunnableProcess stdin) {
    // fProcess.then((stdoutProcess) {
    //   stdin.fProcess.then<void>(
    //       (stdInProcess) => stdoutProcess.stdout.pipe(stdInProcess.stdin));

    // });

    fProcess.then((lhsProcess) {
      stdin.fProcess.then<void>((rhsProcess) {
        // lhs.stdout -> rhs.stdin
        lhsProcess.stdout.listen(rhsProcess.stdin.add);
        // lhs.stderr -> rhs.stdin
        lhsProcess.stderr.listen(rhsProcess.stdin.add).onDone(() {
          rhsProcess.stdin.close();
        });

        // wire rhs to the console, but thats not our job.
        // rhsProcess.stdout.listen(stdout.add);
        // rhsProcess.stderr.listen(stderr.add);

        // If the rhs process shutsdown before the lhs
        // process we will get a broken pipe. We
        // can safely ignore broken pipe errors (I think :).
        rhsProcess.stdin.done.catchError(
          (Object e) {
            // forget broken pipe after rhs terminates before lhs
          },
          test: (e) =>
              e is SocketException && e.osError.message == 'Broken pipe',
        );
      });
    });
  }

  // Monitors the process until it exists.
  // If a LineAction exists we call
  // line action each time the process emmits a line.
  /// The [nothrow] argument is EXPERIMENTAL
  void processUntilExit(Progress progress, {@required bool nothrow}) {
    var done = Completer<bool>();

    Progress forEach;

    forEach = progress ?? Progress.forEach();

    fProcess.then((process) {
      /// handle stdout stream
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        forEach.addToStdout(line);
      });

      // handle stderr stream
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        forEach.addToStderr(line);
      });
      // trap the process finishing
      process.exitCode.then((exitCode) {
        // CONSIDER: do we pass the exitCode to ForEach or just throw?
        // If the start failed we don't want to rethrow
        // as the exception will be thrown async and it will
        // escape as an unhandled exception and stop the whole script
        forEach.exitCode = exitCode;
        if (exitCode != 0 && nothrow == false) {
          done.completeError(RunException(exitCode,
              'The command ${red('[$cmdLine]')} failed with exitCode: ${exitCode}'));
        } else {
          done.complete(true);
        }
      });
    }).catchError((Object e, StackTrace s) {
      // TODO what should happen here?
      Settings().verbose(
          '${e.toString()} stacktrace: ${StackTraceImpl.fromStackTrace(s).formatStackTrace()}');
      // print('caught ${e}');
      // throw e;
    }); // .whenComplete(() => print('start completed'));

    try {
      // wait for the process to finish.
      waitForEx<bool>(done.future);
    } catch (e) {
      rethrow;
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
