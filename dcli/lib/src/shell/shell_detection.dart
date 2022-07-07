/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import '../../dcli.dart';
import '../../posix.dart';
import '../../windows.dart';
import 'docker_shell.dart';
import 'shell_mixin.dart';

/// The project:
/// https://github.com/sarugaku/shellingham
///
/// is a useful reference on shell detection.

///
/// Provides some conveinence funtions to get access to
/// details about the system shell (e.g. bash) that we were run from.
///
/// Note: when you start up dcli from the cli there are three processes
/// involved:
///
/// cli - the cli you started dcli from. This is the shell we will return
/// sh - the shebang (#!) spawns an 'sh' shell which dart is run under.
/// dart - the dart process
///
/// This class is considered EXPERIMENTAL and is likely to change.
class ShellDetection {
  /// obtain a singleton instance of Shell.
  factory ShellDetection() => _shell;

  ShellDetection._internal();

  static final ShellDetection _shell = ShellDetection._internal();

  final _shells = <String, Shell Function(int? pid)>{
    AshShell.shellName: AshShell.withPid,
    CmdShell.shellName: CmdShell.withPid,
    DashShell.shellName: DashShell.withPid,
    BashShell.shellName: BashShell.withPid,
    PowerShell.shellName: PowerShell.withPid,
    ShShell.shellName: ShShell.withPid,
    ZshShell.shellName: ZshShell.withPid,
    FishShell.shellName: FishShell.withPid,
    DockerShell.shellName: DockerShell.withPid,
  };

  /// Attempts to identify the shell that
  /// DCli was run under.
  /// Ignores the 'sh' instances used by #! to start
  /// a DCli script.
  ///
  /// If we can't find a known shell we will return
  /// [UnknownShell].
  /// If the 'sh' instance created by #! is the only
  /// known shell we detect then we will return that
  /// shell [ShShell].
  ///
  /// Currently this isn't very reliable.
  Shell identifyShell() {
    /// on posix systems this MAY give us the login shell name.
    final _loginShell = ShellMixin.loginShell();
    if (_loginShell != null) {
      return _shellByName(_loginShell, -1);
    } else {
      return _searchProcessTree();
    }
  }

  Shell _searchProcessTree() {
    Shell? firstShell;
    int? firstPid;
    Shell? shell;
    int? childPID = pid;

    int? priorPID = -1;

    var firstPass = true;
    while (shell == null && childPID != priorPID) {
      final possiblePid = ProcessHelper().getParentPID(childPID);

      /// Check if we ran into the root process or we
      ///  couldn't get the parent pid.
      if (possiblePid == 0 || possiblePid == -1) {
        break;
      }
      var processName = ProcessHelper().getProcessName(possiblePid);
      if (processName != null) {
        processName = processName.toLowerCase();
        verbose(() => 'found: $possiblePid $processName');
        shell = _shellByName(processName, possiblePid);
      } else {
        Settings()
            .verbose('possiblePID: $possiblePid Unable to obtain process name');
        shell = UnknownShell.withPid(possiblePid, processName: 'unknown');
      }

      if (firstPass) {
        firstPass = false;

        /// there may actually be no shell in which
        /// case the firstShell will contain the parent process
        /// and we will return UnknownShell with the parent processes
        /// id
        firstShell = shell;
        firstPid = possiblePid;

        /// If started by #! the parent willl be an 'sh' shell
        ///  which we need to ignore.
        if (shell.name == ShShell.shellName) {
          /// just in case we find no other shells we will return
          /// the sh shell because in theory we can actually be run
          /// from an sh shell.

          shell = null;
        }
      }
      if (shell != null && shell.name == UnknownShell.shellName) {
        shell = null;
      }

      priorPID = childPID;
      childPID = possiblePid;
    }

    /// If we didn't find a shell then use firstShell.
    shell ??= firstShell;
    childPID ??= firstPid;

    /// are we running docker?
    /// We leave this check until then end as we may find an actual
    /// shell even on Docker.
    if (DockerShell.inDocker) {
      shell = DockerShell.withPid(pid);
    }

    /// if things are really sad.
    shell ??= UnknownShell.withPid(childPID);
    verbose(() => blue('Identified shell: ${shell!.name}'));
    return shell;
  }

  /// Returns the shell with the name that matches [processName]
  /// If there is no match then [UnknownShell] is returned.
  Shell _shellByName(String processName, int? pid) {
    Shell? shell;

    final finalprocessName = processName.toLowerCase();

    if (_shells.containsKey(finalprocessName)) {
      shell = _shells[finalprocessName]!.call(pid);
    }

    return shell ??= UnknownShell.withPid(pid, processName: finalprocessName);
  }
}
