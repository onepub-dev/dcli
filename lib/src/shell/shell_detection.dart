import 'dart:io';

import '../../dshell.dart';
import 'ash_shell.dart';
import 'bash_shell.dart';
import 'cmd_shell.dart';
import 'dash_shell.dart';
import 'power_shell.dart';
import 'sh_shell.dart';
import 'shell_mixin.dart';
import 'unknown_shell.dart';
import 'zshell.dart';

/// The project:
/// https://github.com/sarugaku/shellingham
///
/// is a useful reference on shell detection.

///
/// Provides some conveinence funtions to get access to
/// details about the system shell (e.g. bash) that we were run from.
///
/// Note: when you start up dshell from the cli there are three processes
/// involved:
///
/// cli - the cli you started dshell from. This is the shell we will return
/// sh - the shebang (#!) spawns a [sh] shell which dart is run under.
/// dart - the dart process
///
/// This class is considered EXPERIMENTAL and is likely to change.
class ShellDetection {
  static final ShellDetection _shell = ShellDetection._internal();

  final _shells = <String, Shell Function(int pid)>{
    AshShell.shellName: (pid) => AshShell(),
    CmdShell.shellName: (pid) => CmdShell(),
    DashShell.shellName: (pid) => DashShell(),
    BashShell.shellName: (pid) => BashShell(),
    PowerShell.shellName: (pid) => PowerShell(),
    ShShell.shellName: (pid) => ShShell(),
    ZshShell.shellName: (pid) => ZshShell(),
  };

  ShellDetection._internal();

  /// obtain a singleton instance of Shell.
  factory ShellDetection() => _shell;

  /// Attempts to identify the shell that
  /// DShell was run under.
  /// Ignores the 'sh' instances used by #! to start
  /// a DShell script.
  ///
  /// We we can't find a known shell we will return
  /// [UnknownShell].
  /// If the 'sh' instance created by #! is the only
  /// known shell we detect then we will return that
  /// shell [ShShell].
  ///
  /// Currently this isn't very reliable.
  Shell identifyShell() {
    /// on posix systems this MAY give us the login shell name.
    var _loginShell = ShellMixin.loginShell();
    if (_loginShell != null) {
      return _shellByName(_loginShell);
    } else {
      return _searchProcessTree();
    }
  }

  Shell _searchProcessTree() {
    Shell firstShell;
    Shell shell;
    var childPID = pid;

    var firstPass = true;
    while (shell == null) {
      var possiblePid = ProcessHelper().getParentPID(childPID);

      /// Check if we ran into the root process.
      if (possiblePid == 0) {
        break;
      }
      var processName =
          ProcessHelper().getProcessName(possiblePid).toLowerCase();
      Settings().verbose('parentPID: $possiblePid $processName');

      shell = _shellByName(processName);

      Settings().verbose('found: $possiblePid $processName');

      if (firstPass) {
        firstPass = false;

        /// there may actually be no shell in which
        /// case the firstShell will contain the parent process
        /// and we will return UnknownShell with the parent processes
        /// id
        firstShell = shell;

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

      childPID = possiblePid;
    }

    /// If we didn't find a shell then use firstShell.
    shell ??= firstShell;
    Settings().verbose(blue('Identified shell: ${shell.name}'));
    return shell;
  }

  /// Returns the shell with the name that matches [processName]
  /// If there is no match then [UnknownShell] is returned.
  Shell _shellByName(String processName) {
    Shell shell;

    processName = processName.toLowerCase();

    if (_shells.containsKey(processName)) {
      shell = _shells[processName].call(pid);
    }

    shell ??= UnknownShell(processName);
    return shell;
  }
}
