import 'dart:io';

import '../../dcli.dart';
import '../installers/linux_installer.dart';
import '../installers/macosx_installer.dart';

/// Provides a number of helper functions
/// when for posix based shells.
mixin PosixMixin {
  String get startScriptName;

  String get pathToStartScript {
    return join(HOME, startScriptName);
  }

  /// Adds the given path to the zsh path if it isn't
  /// already on teh path.
  bool addToPATH(String path) {
    if (!isOnPATH(path)) {
      var export = 'export PATH=\$PATH:$path';

      var rcPath = pathToStartScript;

      if (!exists(rcPath)) {
        rcPath.write(export);
      } else {
        rcPath.append(export);
      }
    }
    return true;
  }

  bool get isCompletionInstalled {
    var completeInstalled = false;
    var startFile = pathToStartScript;

    if (startFile != null) {
      if (exists(startFile)) {
        read(startFile).forEach((line) {
          if (line.contains('dcli_complete')) {
            completeInstalled = true;
          }
        });
      }
    }
    return completeInstalled;
  }

  bool get isPrivilegedUser {
    var user = _whoami();
    var privileged = (user == 'root');
    Settings().verbose('isPrivilegedUser: $privileged');
    return privileged;
  }

  String get loggedInUser {
    var user = _whoami();
    if (user == 'root') {
      user = env['SUDO_USER'];
    }
    Settings().verbose('loggedInUser: $user');
    return user;
  }

  String _whoami() {
    var user = 'whoami'.firstLine;
    Settings().verbose('whoami: $user');
    return user;
  }

  String privilegesRequiredMessage(String app) {
    return 'Please run with: sudo $app';
  }

  bool install() {
    if (Platform.isLinux) {
      return LinuxDCliInstaller().install();
    } else {
      return MacOsxDCliInstaller().install();
    }
  }

  /// at this point no posix system has any preconditions.
  String checkInstallPreconditions() => null;
}
