/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';
import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:native_synchronization/mailbox.dart';
import 'package:path/path.dart';

import '../../dcli.dart';
import '../process/environment.dart';
import '../process/process/message.dart';
import '../process/process/message_response.dart';
import '../process/process/process_in_isolate2.dart';
import '../process/process/process_settings.dart';
import '../progress/progress_impl.dart';
import 'capture.dart';
import 'parse_cli_command.dart';

/// [printerr] provides the equivalent functionality to the
/// standard Dart print function but instead writes
/// the output to stderr rather than stdout.
///
/// CLI applications should, by convention, write error messages
/// out to stderr and expected output to stdout.
///
/// Calls toString on [object] and writes it to stderr.
void printerr(Object? object) {
  final line = '$object';

  /// Co-operate with runDCliZone
  final overloaded = Zone.current[capturePrinterrKey] as CaptureZonePrintErr?;
  if (overloaded != null) {
    overloaded(line);
  } else {
    stderr.writeln(line);
  }
}

///
class RunnableProcess {
  RunnableProcess._internal(this._parsed, this.workingDirectory) {
    // _streamsFlushed =
    // ignore: discarded_futures
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

  // late Future<Process> _fProcess;

  /// The running process.
  // ProcessSync? processSync;

  /// The directory the process is running in.
  final String? workingDirectory;

  final ParsedCliCommand _parsed;

  /// Used when the process is exiting to ensure that we wait
  /// for stdout and stderr to be flushed.
  final Completer<void> _stdoutFlushed = Completer<void>();
  final Completer<void> _stderrFlushed = Completer<void>();
  // late Future<List<void>> _streamsFlushed;

  /// returns the original command line that started this process.
  String get cmdLine => '${_parsed.cmd} ${_parsed.args.join(' ')}';

  /// Experiemental - DO NOT USE
  Stream<List<int>> get stream {
    // TODO: re-implent streams.
    throw ProcessException(_parsed.cmd, _parsed.args, 'Not supported');
    // wait until the process has started
    // final process = waitForEx<Process>(_fProcess);
    // return process.stdout;
  }

  /// Experiemental - DO NOT USE
  Sink<List<int>> get sink {
    // TODO: re-implent streams.
    throw ProcessException(_parsed.cmd, _parsed.args, 'Not supported');
    // wait until the process has started
    // final process = waitForEx<Process>(_fProcess);
    // return process.stdin;
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
  Future<Progress> runStreaming({
    Progress? progress,
    bool runInShell = false,
    bool privileged = false,
    bool nothrow = false,
    bool extensionSearch = true,
  }) async {
    progress ??= Progress.devNull();

    // start(
    //   runInShell: runInShell,
    //   privileged: privileged,
    //   extensionSearch: extensionSearch,
    // );
    // await processStream(progress, nothrow: nothrow);

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
        nothrow: nothrow,
        progress: progress as ProgressImpl,
      );
      // if (terminal == true) {
      //   /// we can't process io as the terminal
      //   // has inherited the IO so we dont' see it.
      //   _waitForExit(processSync!, progress, nothrow: nothrow);
      // } else {

      // ignore: discarded_futures, cascade_invocations

      _logProcess('spawn completed - waithing for process exit');

      /// whether we have a terminal or not we use the same
      /// process to read any io that comes back until
      /// we see an exit code.
      if (detached == false) {
        if (exitCode != 0 && nothrow == false) {
          throw RunException.withArgs(
            _parsed.cmd,
            _parsed.args,
            exitCode,
            'The command '
            // ignore: lines_longer_than_80_chars
            '${red('[${_parsed.cmd}] with args [${_parsed.args.join(', ')}]')}'
            ' failed with exitCode: $exitCode '
            'workingDirectory: $workingDirectory',
          );
        }
      }
      // else we are detached and won't see the child exit
      // so no point waiting.
      // }
    } finally {
      (progress as ProgressImpl).close();
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
    required ProgressImpl progress,
    bool nothrow = false,
    bool runInShell = false,
    bool detached = false,
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
      _parsed.cmd = searchForCommandExtension(_parsed.cmd, workingDirectory);
    }

    /// On linux/MacOS if this needs to be a privileged operation
    /// and we are not a privileged user, then
    /// we add 'sudo' in front of the command.
    if (privileged && !Settings().isWindows) {
      if (!Shell.current.isPrivilegedUser) {
        if (which('sudo').found) {
          _parsed.args.insert(0, _parsed.cmd);
          _parsed.cmd = 'sudo';
        } else {
          verbose(() =>
              "privileged was requested but  sudo doesn't exist on the path");
        }
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

    final processSettings = ProcessSettings(_parsed.cmd,
        args: _parsed.args,
        workingDirectory: workdir,
        runInShell: runInShell,
        detached: detached,
        terminal: terminal,
        privileged: privileged,
        extensionSearch: extensionSearch,
        environment: ProcessEnvironment());

    late final mailboxFromPrimaryIsolate = Mailbox();
    final mailboxToPrimaryIsolate = Mailbox();

    startIsolate2(
        processSettings, mailboxFromPrimaryIsolate, mailboxToPrimaryIsolate);

    MessageResponse response;
    do {
      response = MessageResponse.fromData(mailboxToPrimaryIsolate.take())
        ..onStdout((payload) {
          progress.addToStdout(payload);
        })
        ..onStderr((payload) {
          progress.addToStderr(payload);
        })
        ..onException((exception) =>
            Error.throwWithStackTrace(exception, exception.stackTrace));
    } while (response.messageType != MessageType.exitCode);

    response.onExit((exitCode) {
      if (exitCode != 0 && nothrow == false) {
        throw RunException.withArgs(
          _parsed.cmd,
          _parsed.args,
          exitCode,
          'The command '
          '${red('[${_parsed.cmd}] with args [${_parsed.args.join(', ')}]')} '
          'failed with exitCode: $exitCode '
          'workingDirectory: $workingDirectory',
        );
      } else {
        progress.exitCode = exitCode;
      }
    });
  }

  /// TODO: does this work now we have moved to mailboxes?
  // void pipeTo(RunnableProcess stdin) {
  //   // fProcess.then((stdoutProcess) {
  //   //   stdin.fProcess.then<void>(
  //   //       (stdInProcess) => stdoutProcess.stdout.pipe(stdInProcess.stdin));

  //   // });

  //   /// this code was unawaited so pipeTo is probably not going to
  //   /// work without a re-write
  //   final lhsProcess = processSync;
  //   final rhsProcess = stdin.processSync;
  //   // lhs.stdout -> rhs.stdin
  //   lhsProcess.stdout.listen(rhsProcess!.stdin.add);
  //   // lhs.stderr -> rhs.stdin
  //   lhsProcess.stderr
  //       .listen(rhsProcess.stdin.add)
  //       .onDone(rhsProcess.stdin.close);

  //   // wire rhs to the console, but thats not our job.
  //   // rhsProcess.stdout.listen(stdout.add);
  //   // rhsProcess.stderr.listen(stderr.add);

  //   // If the rhs process shutsdown before the lhs
  //   // process we will get a broken pipe. We
  //   // can safely ignore broken pipe errors (I think :).
  //   rhsProcess.stdin.done.catchError(
  //     //ignore: avoid_types_on_closure_parameters
  //     (Object e) {
  //       // forget broken pipe after rhs terminates before lhs
  //     },
  //     test: (e) => e is SocketException && e.osError!.message
  //          == 'Broken pipe',
  //   );
  // }

  /// Unlike [processUntilExit] this method wires the streams and then returns
  /// immediately.
  ///
  /// When the process exits it closes the [progress] streams.
  ///
  // Future<void> processStream(Progress progress, {required bool nothrow})
  //async {
  //   _wireStreams(processSync!, progress);

  // trap the process finishing

  // this makes no sense as we want the process to run whilst
  // we process its output so waiting for exit stops us doing that.
  // final exitCode = processSync!.waitForExitCode;
  // CONSIDER: do we pass the exitCode to ForEach or just throw?
  // If the start failed we don't want to rethrow
  // as the exception will be thrown async and it will
  // escape as an unhandled exception and stop the whole script
  // progress.exitCode = exitCode;
  // if (exitCode != 0 && nothrow == false) {
  //   final error = RunException.withArgs(
  //     _parsed.cmd,
  //     _parsed.args,
  //     exitCode,
  //     'The command '
  //     // ignore: lines_longer_than_80_chars
  //     '${red('[${_parsed.cmd}] with args [${_parsed.args.join(', ')}]')}'
  //     ' failed with exitCode: $exitCode '
  //     'workingDirectory: $workingDirectory',
  //   );
  //   progress
  //     ..onError(error)
  //     ..close();
  // } else {
  //   /// don't think this is neccessary as we are using
  //   // await _streamsFlushed;
  //   progress.close();
  // }
  // }
}

String searchForCommandExtension(String cmd, String? workingDirectory) {
  // if the cmd has an extension they we don't need to find
  // its extension.
  if (extension(cmd).isNotEmpty) {
    return cmd;
  }

  // if the cmd has a path then
  // we only search the cmd's directory
  if (dirname(cmd) != '.') {
    final resolvedPath = join(workingDirectory ?? '.', dirname(cmd));
    return findExtension(basename(cmd), resolvedPath);
  }

  // just the cmd so run which with searchExtension.
  return basename(which(cmd).path ?? cmd);
}

///  Searches for a file in [workingDirectory] that matches [basename]
///  with one of the defined Windows extensions
String findExtension(String basename, String workingDirectory) {
  for (final extension in env['PATHEXT']!.split(';')) {
    final cmd = '$basename$extension';
    if (exists(join(workingDirectory, cmd))) {
      return cmd;
    }
  }
  return basename;
}

void _logProcess(String message) {
  if (debugIsolate) {
    print('process: $message');
  }
}
