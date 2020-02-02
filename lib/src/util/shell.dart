import 'dart:io';
import 'package:dshell/dshell.dart';

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

/// an abstract class which allows each shell (bash, zsh)
/// to provide specific implementation of features
/// required by DShell.
abstract class Shell {
  bool get isCompletionInstalled;

  bool get isCompletionSupported;

  /// If the shell supports tab completion then
  /// install it.
  void installTabCompletion();

  /// Returns the path to the shell's start script
  String get startScriptPath;

  /// Returns the  name of the shell's startup script
  /// e.g. .bashrc
  String get startScriptName;

  /// The name of the shell
  /// e.g. bash
  String get name;

  /// Added a path to the start script
  /// returns true if adding the path was successful
  bool addToPath(String path);
}

class BashShell implements Shell {
  @override
  String get startScriptPath {
    return join(HOME, startScriptName);
  }

  @override
  bool get isCompletionSupported => true;

  @override
  bool get isCompletionInstalled {
    var completeInstalled = false;
    var startFile = startScriptPath;

    if (startFile != null) {
      if (exists(startFile)) {
        read(startFile).forEach((line) {
          if (line.contains('dshell_complete')) {
            completeInstalled = true;
          }
        });
      }
    }
    return completeInstalled;
  }

  // adds bash cli completion for dshell
  // by adding a 'complete' command to ~/.bashrc
  @override
  void installTabCompletion() {
    if (!isCompletionInstalled) {
      // Add cli completion
      var command = "complete -C 'dshell_complete' dshell";

      var startFile = startScriptPath;

      if (startFile != null) {
        if (!exists(startFile)) {
          touch(startFile, create: true);
        }
        startFile.append(command);

        print(
            'dshell tab completion installed. Restart your terminal to activate it.');
      } else {
        printerr(red('Unable to install dshell tab completion'));
        printerr(
            "Add ${orange('$command')} to your start up script to enable tab completion");
      }
    }
  }

  @override
  String get name => 'Bash';

  @override
  String get startScriptName {
    return '.bashrc';
  }

  /// Adds the given path to the bash path if it isn't
  /// already on teh path.
  @override
  bool addToPath(String path) {
    if (!isOnPath(path)) {
      var export = 'export PATH=\$PATH:$path';

      var rcPath = startScriptPath;

      if (!exists(rcPath)) {
        rcPath.write(export);
      } else {
        rcPath.append(export);
      }
    }
    return true;
  }
}

class ZshShell implements Shell {
  @override
  String get startScriptPath {
    return join(HOME, startScriptName);
  }

  @override
  bool get isCompletionSupported => false;

  @override
  bool get isCompletionInstalled => false;

  @override
  void installTabCompletion() {}

  @override
  String get name => 'zsh';

  @override
  String get startScriptName {
    return '.zshrc';
  }

  /// Adds the given path to the zsh path if it isn't
  /// already on teh path.
  @override
  bool addToPath(String path) {
    if (!isOnPath(path)) {
      var export = 'export PATH=\$PATH:$path';

      var rcPath = startScriptPath;

      if (!exists(rcPath)) {
        rcPath.write(export);
      } else {
        rcPath.append(export);
      }
    }
    return true;
  }
}

class UnknownShell implements Shell {
  @override
  bool addToPath(String path) {
    if (Settings().isMacOS) {
      return addPathToMacOsPathd(path);
    } else if (Settings().isLinux) {
      return addPathToLinxuPath(path);
    } else {
      return false;
    }
  }

  bool addPathToMacOsPathd(String path) {
    var success = false;
    if (!isOnPath(path)) {
      var macOSPathPath = join('/etc', 'path.d');

      try {
        if (!exists(macOSPathPath)) {
          createDir(macOSPathPath, recursive: true);
        }
        if (exists(macOSPathPath)) {
          join(macOSPathPath, 'dshell').write(path);
        }
        success = true;
      } catch (e) {
        // ignore write permission problems.
        printerr(red(
            "Unable to add dshell/bin to path as we couldn't write to $macOSPathPath"));
      }
    }
    return success;
  }

  bool addPathToLinxuPath(String path) {
    var success = false;
    if (!isOnPath(path)) {
      var profile = join(HOME, '.profile');
      try {
        if (exists(profile)) {
          var export = 'export PATH=\$PATH:$path';
          if (!read(profile).toList().contains(export)) {
            profile.append(export);
            success = true;
          }
        }
      } catch (e) {
        // ignore write permission problems.
        printerr(red(
            "Unable to add dshell/bin to path as we couldn't write to $profile"));
      }
    }
    return success;
  }

  @override
  void installTabCompletion() {}

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => 'Unknown';

  @override
  String get startScriptName => null;

  @override
  String get startScriptPath => null;
}
