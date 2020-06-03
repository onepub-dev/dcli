import '../../dshell.dart';

/// Provides a number of helper functions
/// when dshell needs to interact with the Bash shell.

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

  @override
  bool get isPrivilegedUser {
    var user = 'whoami'.firstLine;
    Settings().verbose('user: $user');
    var privileged = (user == 'root');
    Settings().verbose('isPrivilegedUser: $privileged');
    return privileged;
  }

  @override
  String get loggedInUser {
    String user;

    var line = 'who'.firstLine;
    Settings().verbose('who: $line');
    // username :1
    var parts = line.split(':');
    if (parts.isNotEmpty) {
      user = parts[0];
    }
    Settings().verbose('loggedInUser: $user');
    return user;
  }

  @override
  String privilegesRequiredMessage(String app) {
    return 'Please run with: sudo $app';
  }
}
