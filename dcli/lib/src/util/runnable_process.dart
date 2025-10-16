/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart';

import '../../dcli.dart';
import '../process/environment.dart';
import '../process/process/isolate_channel.dart';
import '../process/process/message.dart';
import '../process/process/message_response.dart';
import '../process/process/process_in_isolate.dart';
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
  /// The running process.
  // ProcessSync? processSync;

  /// The directory the process is running in.
  final String? workingDirectory;

  final ParsedCliCommand _parsed;

  /// Used when the process is exiting to ensure that we wait
  /// for stdout and stderr to be flushed.
  final _stdoutFlushed = Completer<void>();

  final _stderrFlushed = Completer<void>();

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

  /// returns the original command line that started this process.
  String get cmdLine => '${_parsed.cmd} ${_parsed.args.join(' ')}';

  /// Experiemental - DO NOT USE
  Stream<List<int>> get stream {
    // TODO(bsutton): re-implent streams.
    throw ProcessException(_parsed.cmd, _parsed.args, 'Not supported');
    // wait until the process has started
    // final process = waitForEx<Process>(_fProcess);
    // return process.stdout;
  }

  /// Experiemental - DO NOT USE
  Sink<List<int>> get sink {
    // TODO(bsutton): re-implent streams.
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
  // Future<Progress> runStreaming({
  //   Progress? progress,
  //   bool runInShell = false,
  //   bool privileged = false,
  //   bool nothrow = false,
  //   bool extensionSearch = true,
  // }) async {
  //   progress ??= Progress.devNull();

  //   // start(
  //   //   runInShell: runInShell,
  //   //   privileged: privileged,
  //   //   extensionSearch: extensionSearch,
  //   // );
  //   // await processStream(progress, nothrow: nothrow);

  //   return progress;
  // }

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
  ///
  /// if [nothrow] is false and the command returns a non zero exit code
  /// then a [RunException] is thrown.
  Progress run({
    Progress? progress,
    bool terminal = false,
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

      /// whether we have a terminal or not we use the same
      /// process to read any io that comes back until
      /// we see an exit code.
      if (!detached) {
        if (progress.exitCode != 0 && !nothrow) {
          throw RunException.withArgs(
            _parsed.cmd,
            _parsed.args,
            progress.exitCode,
            'The command '
            '${red('[${_parsed.cmd}] with args [${_parsed.args.join(', ')}]')}'
            ' failed with exitCode: $progress.exitCode '
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
    processLogger(() => 'process completed');
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
      !(terminal && detached),
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

    final channel = IsolateChannel(process: processSettings);

    startIsolate(channel);

    channel.errorPort.listen((error) {
      processLogger(() => red('ErrorPort: $error'));
    });
    channel.exitPort.listen((error) {
      processLogger(() => red('ExitPort: $error'));
    });

    MessageResponse? response;
    try {
      do {
        processLogger(() => 'Primary calling Mailbox.take()');
        try {
          processLogger(() => 'calling Mailbox:take ');

          final messageData = channel.toPrimaryIsolate
              .take(timeout: const Duration(seconds: 2));
          processLogger(
              () => 'take returned with data: len(${messageData.length - 1})');
          response = MessageResponse.fromData(messageData)
            ..onStdout((payload) {
              progress.addToStdout(payload);
            })
            ..onStderr((payload) {
              progress.addToStderr(payload);
            })
            ..onException((exception) =>
                Error.throwWithStackTrace(exception, exception.stackTrace));
        } on TimeoutException catch (e) {
          processLogger(
              () => 'Timeout waiting for response from isolate: ${e.message}');

          /// Paired with take(timeout:), this seems to help reduce stalls
          /// when the isolate is starting up.
          Future.delayed(const Duration(seconds: 3), () {});
        }
      } while (response?.messageType != MessageType.exitCode);

      processLogger(() => 'Exit code recived by primary isolate');

      response?.onExit((exitCode) {
        if (exitCode != 0 && !nothrow) {
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
    } finally {
      /// guarentee we close the ports even if we get an exception
      /// above.
      channel.errorPort.close();
      channel.exitPort.close();
    }
  }
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

String? _isolateID;
void processLogger(String Function() message) {
  if (debugIsolate) {
    _isolateID ??= Service.getIsolateId(Isolate.current);
    print('process($_isolateID): ${message()}');
  }
}
