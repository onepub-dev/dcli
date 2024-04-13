// ignore_for_file: comment_references

import 'dart:io';

import 'package:dcli_core/dcli_core.dart';
import 'package:dcli_terminal/dcli_terminal.dart';

import '../../../util/parse_cli_command.dart';
import '../../../util/runnable_process.dart';
import '../process_settings.dart';

class ProcessRunner {
  ProcessRunner(this.settings) {
    _parsed = ParsedCliCommand.fromParsed(
      settings.command,
      settings.args,
      settings.workingDirectory,
    );
  }
  final ProcessSettings settings;
  late final ParsedCliCommand _parsed;

  Process? process;

  /// Starts a process  provides additional options to [run].
  ///
  /// This is an internal function and should not be exposed.
  /// It requires addition logic to read stdout/stderr or
  /// the running command can end up suspended.
  ///
  /// The [settings.privileged] argument attempts to escalate the priviledge
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
  Future<void> start() async {
    assert(
      !(settings.terminal == true && settings.detached == true),
      'You cannot enable terminal and detached at the same time.',
    );

    var mode =
        settings.detached ? ProcessStartMode.detached : ProcessStartMode.normal;

    // can't use inheritedStdio when we run in an isolate
    // this will need to be somehow managed from the primary isolate.
    if (settings.terminal) {
      mode = ProcessStartMode.inheritStdio;
    }

    if (Settings().isWindows && settings.extensionSearch) {
      _parsed.cmd =
          searchForCommandExtension(_parsed.cmd, settings.workingDirectory);
    }

    /// On linux/MacOS if this needs to be a privileged operation
    /// and we are not a privileged user, then
    /// we add 'sudo' in front of the command.
    if (settings.privileged && !Settings().isWindows) {
      if (!settings.isPriviledgedUser) {
        /// if sudo doesn't exist, no point appending it.
        /// Can happen in a docker container.
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
        () => 'Process.start: runInShell: $settings.runInShell '
            'workingDir: $settings.workingDirectory mode: $mode '
            'cmd: ${_parsed.cmd} args: ${_parsed.args.join(', ')}',
      );
    }

    if (!exists(settings.workingDirectory)) {
      final cmdLine = "${_parsed.cmd} ${_parsed.args.join(' ')}";
      throw RunException(
        cmdLine,
        -1,
        '''The specified workingDirectory [${settings.workingDirectory}] does not exist.''',
      );
    }

    try {
      _logRunner('about to start process');
      process = await Process.start(
        _parsed.cmd,
        _parsed.args,
        runInShell: settings.runInShell,
        workingDirectory: settings.workingDirectory,
        mode: mode,
        environment: settings.environment.envVars,
      );
      _logRunner('runner has started process');
    } on ProcessException catch (e) {
      _logRunner('exception launching process: $e');
      if (e.errorCode == 2) {
        final ep = e;
        throw RunException.withArgs(
          ep.executable,
          ep.arguments,
          ep.errorCode,
          'Could not find ${ep.executable} on the path.',
        );
      } else {
        throw RunException.withArgs(
            e.executable, e.arguments, e.errorCode, e.message);
      }
    }
  }

  // /// Waits for the process to exit
  // /// We use this method when we can't or don't
  // /// want to process IO.
  // /// The main use is when using start(terminal:true).
  // /// We don't have access to any IO so we just
  // /// have to wait for things to finish.
  // int? _waitForExit(Progress progress, {required bool nothrow}) {
  //   final exited = Completer<int>();
  //   unawaited(process.then((process) {
  //     final exitCode = waitForEx<int>(process.exitCode);
  //     progress.exitCode = exitCode;

  //     if (exitCode != 0 && nothrow == false) {
  //       exited.completeError(
  //         RunException.withArgs(
  //           _parsed.cmd,
  //           _parsed.args,
  //           exitCode,
  //           'The command '
  //           '${red('[${_parsed.cmd}] with args '
  //              '[${_parsed.args.join(', ')}]')} '
  //           'failed with exitCode: $exitCode '
  //           'workingDirectory: $workingDirectory',
  //         ),
  //       );
  //     } else {
  //       exited.complete(exitCode);
  //     }
  //   }));
  //   return waitForEx<int>(exited.future);
  // }
}

void _logRunner(String message) {
  // _logRunner(message);
}
