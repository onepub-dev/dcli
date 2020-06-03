import '../../dshell.dart';

/// Provides a number of helper functions
/// when dshell needs to interact with the Zsh shell.
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
