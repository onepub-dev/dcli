import 'dart:io';

import '../../dshell.dart';
import 'bash.dart';
import 'unknown_shell.dart';
import 'zshell.dart';

///
/// Provides some conveinence funtions to get access to
/// details about the system shell (e.g. bash) that we were run from.
///
/// This class is considered EXPERIMENTAL and is likely to change.
class ShellDetection {
  static final ShellDetection _shell = ShellDetection._internal();

  ShellDetection._internal();

  /// obtain a singleton instance of Shell.
  factory ShellDetection() => _shell;

  /// Attempts to identify the shell that
  /// DShell was run under.
  /// Ignores the 'sh' instances used by #! to start
  /// a DShell script.
  ///
  /// Currently this isn't very reliable.
  Shell identifyShell() {
    Shell shell;
    var shellName = ShellDetection().getShellName().toLowerCase();

    if (shellName == BashShell().name.toLowerCase()) {
      shell = BashShell();
    } else if (shellName == ZshShell().name.toLowerCase()) {
      shell = ZshShell();
    } else {
      shell = UnknownShell();
    }
    Settings().verbose(blue('Identified shell: $shellName'));
    return shell;
  }

  /// Gets the name of the shell that this dshell
  /// script is running under.
  ///
  /// Note: when you start up dshell there are three processes
  /// involved:
  ///
  /// cli - the cli you started dshell from. This is the shell we will return
  /// sh - the shebang (#!) spawns a [sh] shell which dart is run under.
  /// dart - the dart process
  ///
  /// Your dshell script runs within the above dart process.
  /// See [getShellPID]
  String getShellName() {
    var shellName = 'unknown';
    try {
      shellName = ProcessHelper().getProcessName(getShellPID());
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      /// returns 'unknown'
    }
    return shellName;
  }

  /// Gets the name of the pid that this dshell
  /// script is running under.
  ///
  /// Note: when you start up a dshell script there are three processes
  /// involved:
  ///
  /// cli - the cli you started dshell from. This is the shell pid we will return
  /// sh - the shebang (#!) spawns a [sh] shell which dart is run under.
  /// dart - the dart process
  ///
  /// Your dshell script runs within the above dart process.
  int getShellPID({int childPID}) {
    childPID ??= pid;

    int shellPID;

    var dartPID = ProcessHelper().getParentPID(childPID);
    Settings().verbose(
        'dartPID: $dartPID ${ProcessHelper().getProcessName(dartPID)}');
    var envPID = ProcessHelper().getParentPID(dartPID);
    Settings()
        .verbose('envPID: $envPID ${ProcessHelper().getProcessName(envPID)}');

    if (ProcessHelper().getProcessName(envPID).toLowerCase() == 'sh') {
      shellPID = ProcessHelper().getParentPID(envPID);
      // Settings().verbose('shellPID: $envPID ${getPIDName(shellPID)}');
    } else {
      // if you run dshell directly then we don't use #! so 'sh' won't be our parent
      // instead the actuall shell will be our parent.
      shellPID = envPID;
    }
    return shellPID;
  }

  // /// Attempts to identify the shell that
  // /// we are running under and returns the
  // /// path to the shell's configuration file
  // /// e.g. .bashrc.
  // String getShellStartScriptPath() {
  //   var shell = Shell().identifyShell();

  //   String configFile;
  //   if (shell == SHELL.BASH) {
  //     configFile = join(HOME, '.bashrc');
  //   }
  //   if (shell == SHELL.ZSH) {
  //     configFile = join(HOME, '.zshrc');
  //   }

  //   return configFile;
  // }
}
