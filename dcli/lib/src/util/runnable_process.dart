/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';
import 'parse_cli_command.dart';

/// [printerr] provides the equivalent functionality to the
/// standard Dart print function but instead writes
/// the output to stderr rather than stdout.
///
/// CLI applications should, by convention, write error messages
/// out to stderr and expected output to stdout.
///
/// [line] the line to write to stderr.
void printerr(String? line) {
  /// Co-operate with runDCliZone
  final overloaded = Zone.current[DCliZone.printerrKey] as DCliZonePrintErr?;
  if (overloaded != null) {
    overloaded(line);
  } else {
    stderr.writeln(line);
  }
}

///
class RunnableProcess {
  RunnableProcess._internal(this._parsed, this.workingDirectory) {
    _streamsFlushed =
        Future.wait<void>([_stdoutFlushed.future, _stderrFlushed.future]);
  }

  /// Spawns a process to run the command contained in [cmdLine] along with
  /// the args passed via the [cmdLine].
  ///
  /// Glob expansion is performed on each non-quoted argument.
  ///
  RunnableProcess.fromCommandLine(String cmdLine, {String? workingDirectory})
      : this._internal(
          ParsedCliCommand(cmdLine, workingDirectory),
          workingDirectory,
        );

  /// Spawns a process to run the command contained in [command] along with
  /// the args passed via the [args].
  ///
  /// Glob expansion is performed on each non-quoted argument.
  ///
  RunnableProcess.fromCommandArgs(
    String command,
    List<String> args, {
    String? workingDirectory,
  }) : this._internal(
          ParsedCliCommand.fromParsed(command, args, workingDirectory),
          workingDirectory,
        );

  late Future<Process> _fProcess;

  /// The directory the process is running in.
  final String? workingDirectory;

  final ParsedCliCommand _parsed;

  /// Used when the process is exiting to ensure that we wait
  /// for stdout and stderr to be flushed.
  final Completer<void> _stdoutFlushed = Completer<void>();
  final Completer<void> _stderrFlushed = Completer<void>();
  late Future<List<void>> _streamsFlushed;

  /// returns the original command line that started this process.
  String get cmdLine => '${_parsed.cmd} ${_parsed.args.join(' ')}';

  /// Experiemental - DO NOT USE
  Stream<List<int>> get stream {
    // wait until the process has started
    final process = waitForEx<Process>(_fProcess);
    return process.stdout;
  }

  /// Experiemental - DO NOT USE
  Sink<List<int>> get sink {
    // wait until the process has started
    final process = waitForEx<Process>(_fProcess);
    return process.stdin;
  }

  /// runs the process and returns as soon as the process
  /// has started.
  ///
  /// This method is used to stream apps output when
  /// using [Progress.stream].
  ///
  /// The [privileged] argument attempts to escalate the priviledge
  /// that the command is run
  /// at.
  /// If the script is already running in a priviledge environment
  /// this switch will have no
  /// affect.
  /// Running a command with the [privileged] switch may cause the
  /// OS to prompt the user
  /// for a password.
  ///
  /// For Linux passing the [privileged] argument will cause the
  /// command to be prefix
  /// vai the `sudo` command.
  ///
  /// Current [privileged] is only supported under Linux.
  ///
  Progress runStreaming({
    Progress? progress,
    bool runInShell = false,
    bool privileged = false,
    bool nothrow = false,
    bool extensionSearch = true,
  }) {
    progress ??= Progress.devNull();

    start(
      runInShell: runInShell,
      privileged: privileged,
      extensionSearch: extensionSearch,
    );
    processStream(progress, nothrow: nothrow);

    return progress;
  }

  /// runs the process.
  ///
  /// Any output from the command (stderr and stdout) is displayed
  ///  on the console.
  ///
  /// Pass an appropriate [progress] if you want to print either of these.
  ///
  /// The [privileged] argument attempts to escalate the priviledge
  /// that the command is run
  /// at.
  /// If the script is already running in a priviledge environment
  /// this switch will have no
  /// affect.
  /// Running a command with the [privileged] switch may cause the
  /// OS to prompt the user
  /// for a password.
  ///
  /// For Linux passing the [privileged] argument will cause the
  /// command to be prefix
  /// vai the `sudo` command.
  ///
  /// Current [privileged] is only supported under Linux.
  ///
  /// If you pass [detached] = true then the process is spawned but we
  /// don't wait for it to complete nor is any io available.
  Progress run({
    required bool terminal,
    Progress? progress,
    bool runInShell = false,
    bool detached = false,
    bool privileged = false,
    bool nothrow = false,
    bool extensionSearch = true,
  }) {
    progress ??= Progress.print();

    try {
      start(
        runInShell: runInShell,
        detached: detached,
        terminal: terminal,
        privileged: privileged,
        extensionSearch: extensionSearch,
      );
      if (terminal == true) {
        /// we can't process io as the terminal
        // has inherited the IO so we dont' see it.
        _waitForExit(progress, nothrow: nothrow);
      } else {
        if (detached == false) {
          processUntilExit(progress, nothrow: nothrow);
        }
        // else we are detached and won't see the child exit
        // so no point waiting.
      }
    } finally {
      progress.close();
    }
    return progress;
  }

  /// Starts a process  provides additional options to [run].
  ///
  /// This is an internal function and should not be exposed.
  /// It requires addition logic to read stdout/stderr or
  /// the running command can end up suspended.
  ///
  /// The [privileged] argument attempts to escalate the priviledge
  /// that the command is run with.
  /// If the script is already running in a priviledge environment
  /// this switch will have no affect.
  ///
  /// Running a command with the [privileged] switch may cause the
  /// OS to prompt the user for a password.
  ///
  /// For Linux passing the [privileged] argument will cause the
  ///  command to be prefix vai the `sudo` command.
  ///
  /// The [privileged] option is ignored under Windows.
  ///
  /// If you pass [detached] = true then the process is spawned
  /// but we don't wait for it to complete nor is any io available.
  void start({
    bool runInShell = false,
    bool detached = false,
    bool waitForStart = true,
    bool terminal = false,
    bool privileged = false,
    bool extensionSearch = true,
  }) {
    var workdir = workingDirectory;
    workdir ??= Directory.current.path;

    assert(
      !(terminal == true && detached == true),
      'You cannot enable terminal and detached at the same time.',
    );

    var mode = detached ? ProcessStartMode.detached : ProcessStartMode.normal;
    if (terminal) {
      mode = ProcessStartMode.inheritStdio;
    }

    if (core.Settings().isWindows && extensionSearch) {
      _parsed.cmd = _searchForCommandExtension(_parsed.cmd, workingDirectory);
    }

    /// On linux/MacOS if this needs to be a privileged operation
    /// and we are not a privileged user, then
    /// we add 'sudo' in front of the command.
    if (privileged && !Settings().isWindows) {
      if (!Shell.current.isPrivilegedUser) {
        _parsed.args.insert(0, _parsed.cmd);
        _parsed.cmd = 'sudo';
      }
    }

    if (Settings().isVerbose) {
      final cmdLine = "${_parsed.cmd} ${_parsed.args.join(' ')}";
      verbose(() => 'Process.start: cmdLine ${green(cmdLine)}');
      verbose(
        () => 'Process.start: runInShell: $runInShell '
            'workingDir: $workingDirectory mode: $mode '
            'cmd: ${_parsed.cmd} args: ${_parsed.args.join(', ')}',
      );
    }

    if (!exists(workdir)) {
      final cmdLine = "${_parsed.cmd} ${_parsed.args.join(' ')}";
      throw RunException(
        cmdLine,
        -1,
        'The specified workingDirectory [$workdir] does not exist.',
      );
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
  }

  void _waitForStart() {
    final complete = Completer<Process>();

    _fProcess.then(complete.complete)
        //ignore: avoid_types_on_closure_parameters
        .catchError((Object e, StackTrace s) {
      // 2 - No such file or directory
      if (e is ProcessException && e.errorCode == 2) {
        final ep = e;
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
  int? _waitForExit(Progress progress, {required bool nothrow}) {
    final exited = Completer<int>();
    _fProcess.then((process) {
      final exitCode = waitForEx<int>(process.exitCode);
      progress.exitCode = exitCode;

      if (exitCode != 0 && nothrow == false) {
        exited.completeError(
          RunException.withArgs(
            _parsed.cmd,
            _parsed.args,
            exitCode,
            'The command '
            '${red('[${_parsed.cmd}] with args [${_parsed.args.join(', ')}]')} '
            'failed with exitCode: $exitCode '
            'workingDirectory: $workingDirectory',
          ),
        );
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
              e is SocketException && e.osError!.message == 'Broken pipe',
        );
      });
    });
  }

  /// Unlike [processUntilExit] this method wires the streams and then returns
  /// immediately.
  ///
  /// When the process exits it closes the [progress] streams.
  void processStream(Progress progress, {required bool nothrow}) {
    _fProcess.then((process) {
      _wireStreams(process, progress);

      // trap the process finishing
      process.exitCode.then((exitCode) {
        // CONSIDER: do we pass the exitCode to ForEach or just throw?
        // If the start failed we don't want to rethrow
        // as the exception will be thrown async and it will
        // escape as an unhandled exception and stop the whole script
        progress.exitCode = exitCode;
        if (exitCode != 0 && nothrow == false) {
          final error = RunException.withArgs(
            _parsed.cmd,
            _parsed.args,
            exitCode,
            'The command '
            // ignore: lines_longer_than_80_chars
            '${red('[${_parsed.cmd}] with args [${_parsed.args.join(', ')}]')}'
            ' failed with exitCode: $exitCode '
            'workingDirectory: $workingDirectory',
          );
          progress
            ..onError(error)
            ..close();
        } else {
          waitForEx<void>(_streamsFlushed);
          progress.close();
        }
      });
    });
  }

  // Monitors the process until it exists.
  // If a LineAction exists we call
  // line action each time the process emmits a line.
  /// The [nothrow] argument is EXPERIMENTAL
  void processUntilExit(Progress? progress, {required bool nothrow}) {
    final exited = Completer<bool>();

    final _progress = progress ?? Progress.devNull();

    _fProcess.then((process) {
      _wireStreams(process, _progress);

      // trap the process finishing
      process.exitCode.then((exitCode) {
        // CONSIDER: do we pass the exitCode to ForEach or just throw?
        // If the start failed we don't want to rethrow
        // as the exception will be thrown async and it will
        // escape as an unhandled exception and stop the whole script
        _progress.exitCode = exitCode;

        /// the process may have exited by the streams are likely to still
        /// contain data.
        _waitForStreams();
        if (exitCode != 0 && nothrow == false) {
          exited.completeError(
            RunException.withArgs(
              _parsed.cmd,
              _parsed.args,
              exitCode,
              'The command '
              // ignore: lines_longer_than_80_chars
              '${red('[${_parsed.cmd}] with args [${_parsed.args.join(', ')}]')}'
              ' failed with exitCode: $exitCode '
              'workingDirectory: $workingDirectory',
            ),
          );
        } else {
          exited.complete(true);
        }
      });
    })
        //ignore: avoid_types_on_closure_parameters
        .catchError((Object e, StackTrace s) {
      verbose(
        () => '${e.toString()} stacktrace: '
            '${StackTraceImpl.fromStackTrace(s).formatStackTrace()}',
      );
      // ignore: only_throw_errors
      throw e;
    }); // .whenComplete(() => print('start completed'));

    try {
      // wait for the process to finish.
      waitForEx<bool>(exited.future);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      rethrow;
    }
  }

  ///
  /// processes both streams until they complete.
  ///
  void _waitForStreams() {
    // Wait for both streams to complete
    waitForEx(Future.wait([_stdoutCompleter.future, _stderrCompleter.future]));
  }

  final _stdoutCompleter = Completer<bool>();
  final _stderrCompleter = Completer<bool>();

  void _wireStreams(Process process, Progress progress) {
    /// handle stdout stream
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      progress.addToStdout(line);
    }).onDone(() {
      _stdoutFlushed.complete();
      _stdoutCompleter.complete(true);
    });

    // handle stderr stream
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      progress.addToStderr(line);
    }).onDone(() {
      _stderrFlushed.complete();
      _stderrCompleter.complete(true);
    });
  }

  String _searchForCommandExtension(String cmd, String? workingDirectory) {
    // if the cmd has an extension they we don't need to find
    // its extension.
    if (extension(cmd).isNotEmpty) {
      return cmd;
    }

    // if the cmd has a path then
    // we only search the cmd's directory
    if (dirname(cmd) != '.') {
      final resolvedPath = join(workingDirectory ?? '.', dirname(cmd));
      return _findExtension(basename(cmd), resolvedPath);
    }

    // just the cmd so run which with searchExtension.
    return basename(which(cmd).path ?? cmd);
  }

  ///  Searches for a file in [workingDirectory] that matches [basename]
  ///  with one of the defined Windows extensions
  String _findExtension(String basename, String workingDirectory) {
    for (final extension in env['PATHEXT']!.split(';')) {
      final cmd = '$basename$extension';
      if (exists(join(workingDirectory, cmd))) {
        return cmd;
      }
    }
    return basename;
  }
}
