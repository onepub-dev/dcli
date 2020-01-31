import 'dart:io';
import 'package:dshell/dshell.dart';

enum SHELL { BASH, ZSH, UNKNOWN }

///
/// Provides some conveinence funtions to get access to
/// details about the system shell (e.g. bash) that we were run from.
///
/// This class is considered EXPERIMENTAL and is likely to change.
class Shell {
  static final Shell _shell = Shell._internal();

  Shell._internal();

  /// obtain a singleton instance of Shell.
  factory Shell() => _shell;

  /// Attempts to identify the shell that
  /// DShell was run under.
  /// Ignores the 'sh' instances used by #! to start
  /// a DShell script.
  ///
  /// Currently this isn't very reliable.
  SHELL identifyShell() {
    SHELL shell;
    var shellName = Shell().getShellName();

    if (shellName.toLowerCase() == 'bash') {
      shell = SHELL.BASH;
    } else if (shellName.toLowerCase() == 'zsh') {
      shell = SHELL.ZSH;
    } else {
      shell = SHELL.UNKNOWN;
    }
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
      shellName = getPIDName(getShellPID());
    } catch (e) {
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

    var dartPID = getParentPID(childPID);
    Settings().verbose('dartPID: $dartPID ${getPIDName(dartPID)}');
    var envPID = getParentPID(dartPID);
    Settings().verbose('envPID: $envPID ${getPIDName(envPID)}');

    if (getPIDName(envPID).toLowerCase() == 'sh') {
      shellPID = getParentPID(envPID);
      // Log.d('shellPID: $envPID ${getPIDName(shellPID)}');
    } else {
      // if you run dshell directly then we don't use #! so 'sh' won't be our parent
      // instead the actuall shell will be our parent.
      shellPID = envPID;
    }
    return shellPID;
  }

  /// Gest the process name for the given pid
  ///
  /// Throws an RunException exception if the name can't
  /// be obtained.
  String getPIDName(int pid) {
    String line;

    try {
      line = 'ps -q $pid -o comm='.firstLine;
    } on ProcessException {
      // ps not supported on current OS
      line = 'unknown';
    }
    if (line != null) {
      line = line.trim();
    }

    return line;
  }

  /// Get the PID of the parent
  /// Throws an RunException exception if the name can't
  /// be obtained.
  ///
  int getParentPID(int childPid) {
    int parentPid;

    String line;
    try {
      line = 'ps -p $childPid -o ppid='.firstLine;
    } on ProcessException {
      // ps not supported on current OS
      line = '-1';
    }
    parentPid = int.tryParse(line.trim());

    return parentPid;
  }

  /// Attempts to identify the shell that
  /// we are running under and returns the
  /// path to the shell's configuration file
  /// e.g. .bashrc.
  String getShellStartScriptPath() {
    var shell = Shell().identifyShell();

    String configFile;
    if (shell == SHELL.BASH) {
      configFile = join(HOME, '.bashrc');
    }
    if (shell == SHELL.ZSH) {
      configFile = join(HOME, '.zshrc');
    }

    return configFile;
  }
}
