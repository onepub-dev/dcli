import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import '../../dshell.dart';
import '../functions/env.dart';
import 'dshell_exception.dart';
import 'parse_cli_command.dart';
import 'progress.dart';
import 'stack_trace_impl.dart';

import 'wait_for_ex.dart';

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

///
class RunnableProcess {
  Future<Process> _fProcess;

  /// The directory the process is running in.
  final String workingDirectory;

  final ParsedCliCommand _parsed;

  /// Spawns a process to run the command contained in [cmdLine] along with
  /// the args passed via the [cmdLine].
  ///
  /// Glob expansion is performed on each non-quoted argument.
  ///
  RunnableProcess.fromCommandLine(String cmdLine, {this.workingDirectory})
      : _parsed = ParsedCliCommand(cmdLine, workingDirectory);

  /// Spawns a process to run the command contained in [command] along with
  /// the args passed via the [args].
  ///
  /// Glob expansion is performed on each non-quoted argument.
  ///
  RunnableProcess.fromCommandArgs(String command, List<String> args,
      {this.workingDirectory})
      : _parsed = ParsedCliCommand.fromParsed(command, args, workingDirectory);

  /// returns the original command line that started this process.
  String get cmdLine => '${_parsed.cmd} ${_parsed.args.join(' ')}';

  /// Experiemental - DO NOT USE
  Stream<List<int>> get stream {
    // wait until the process has started
    var process = waitForEx<Process>(_fProcess);
    return process.stdout;
  }

  /// Experiemental - DO NOT USE
  Sink<List<int>> get sink {
    // wait until the process has started
    var process = waitForEx<Process>(_fProcess);
    return process.stdin;
  }

  /// runs the process.
  Progress run(
      {Progress progress,
      bool runInShell = false,
      bool detached = false,
      String workingDirectory,
      bool terminal,
      bool nothrow}) {
    progress ??= Progress.devNull();

    try {
      start(runInShell: runInShell, detached: detached, terminal: terminal);
      if (detached == false) {
        if (terminal == false) {
          processUntilExit(progress, nothrow: nothrow);
        } else {
          _waitForExit();
        }
      }
    } finally {
      progress.close();
    }
    return progress;
  }

  /// starts the process
  /// provides additional options to [run].
  void start({
    bool runInShell = false,
    bool detached = false,
    bool waitForStart = true,
    bool terminal = false,
  }) {
    var workdir = workingDirectory;
    workdir ??= Directory.current.path;

    assert(!(terminal == true && detached == true),
        'You cannot enable terminal and detached at the same time.');

    var mode = detached ? ProcessStartMode.detached : ProcessStartMode.normal;
    if (terminal) {
      mode = ProcessStartMode.inheritStdio;
    }

    if (Settings().isVerbose) {
      var cmdLine = "${_parsed.cmd} ${_parsed.args.join(' ')}";
      Settings().verbose('Process.start: cmdLine ${green(cmdLine)}');
      Settings().verbose(
          'Process.start: cmd: ${_parsed.cmd} args: ${_parsed.args.join(', ')}');
      Settings().verbose(
          'Process.start(runInShell: $runInShell workingDir: $workingDirectory mode: $mode)');
    }

    _fProcess = Process.start(
      _parsed.cmd,
      _parsed.args,
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
    Settings().verbose('Process.start returned');
  }

  void _waitForStart() {
    var complete = Completer<Process>();

    _fProcess.then((process) {
      complete.complete(process);
    })
        //ignore: avoid_types_on_closure_parameters
        .catchError((Object e, StackTrace s) {
      // 2 - No such file or directory
      if (e is ProcessException && e.errorCode == 2) {
        var ep = e as ProcessException;
        e = RunException.withArgs(
          ep.executable,
          ep.arguments,
          ep.errorCode,
          'Could not find ${ep.executable} on the path.',
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
  int _waitForExit() {
    var exited = Completer<int>();
    _fProcess.then((process) {
      var exitCode = waitForEx<int>(process.exitCode);

      if (exitCode != 0) {
        exited.completeError(RunException.withArgs(
            _parsed.cmd,
            _parsed.args,
            exitCode,
            'The command ${red('[${_parsed.cmd}] with args [${_parsed.args.join(', ')}]')} failed with exitCode: $exitCode'));
      } else {
        exited.complete(exitCode);
      }
    });
    return waitForEx<int>(exited.future);
  }

  ///
  void pipeTo(RunnableProcess stdin) {
    // fProcess.then((stdoutProcess) {
    //   stdin.fProcess.then<void>(
    //       (stdInProcess) => stdoutProcess.stdout.pipe(stdInProcess.stdin));

    // });

    _fProcess.then((lhsProcess) {
      stdin._fProcess.then<void>((rhsProcess) {
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
          //ignore: avoid_types_on_closure_parameters
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

    progress ??= Progress.devNull();

    _fProcess.then((process) {
      /// handle stdout stream
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        progress.addToStdout(line);
      });

      // handle stderr stream
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        progress.addToStderr(line);
      });
      // trap the process finishing
      process.exitCode.then((exitCode) {
        // CONSIDER: do we pass the exitCode to ForEach or just throw?
        // If the start failed we don't want to rethrow
        // as the exception will be thrown async and it will
        // escape as an unhandled exception and stop the whole script
        progress.exitCode = exitCode;
        if (exitCode != 0 && nothrow == false) {
          done.completeError(RunException.withArgs(
              _parsed.cmd,
              _parsed.args,
              exitCode,
              'The command ${red('[${_parsed.cmd}] with args [${_parsed.args.join(', ')}]')} failed with exitCode: $exitCode'));
        } else {
          done.complete(true);
        }
      });
    })
        //ignore: avoid_types_on_closure_parameters
        .catchError((Object e, StackTrace s) {
      Settings().verbose(
          '${e.toString()} stacktrace: ${StackTraceImpl.fromStackTrace(s).formatStackTrace()}');
      throw e;
    }); // .whenComplete(() => print('start completed'));

    try {
      // wait for the process to finish.
      waitForEx<bool>(done.future);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      rethrow;
    }
  }
}

///
class RunException extends DShellException {
  /// The command line that was being run.
  String cmdLine;

  /// the exit code of the command.
  int exitCode;

  /// the error.
  String reason;

  ///
  RunException(this.cmdLine, this.exitCode, this.reason,
      {StackTraceImpl stackTrace})
      : super(reason, stackTrace);

  ///
  RunException.withArgs(
      String cmd, List<String> args, this.exitCode, this.reason,
      {StackTraceImpl stackTrace})
      : cmdLine = '$cmd ${args.join(' ')}',
        super(reason, stackTrace);

  @override
  RunException copyWith(StackTraceImpl stackTrace) {
    return RunException(cmdLine, exitCode, reason, stackTrace: stackTrace);
  }

  @override
  String get message {
    return '''$cmdLine 
exit: $exitCode
reason: $reason''';
  }
}
