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
      final export = 'export PATH=\$PATH:$path';

      final rcPath = pathToStartScript;

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
    final startFile = pathToStartScript;

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
    final user = _whoami();
    final privileged = user == 'root';
    Settings().verbose('isPrivilegedUser: $privileged');
    return privileged;
  }

  String get loggedInUser {
    var user = _whoami();
    if (user == 'root') {
      user = env['SUDO_USER'] ?? 'root';
    }
    Settings().verbose('loggedInUser: $user');
    return user;
  }

  String _whoami() {
    final user = 'whoami'.firstLine;
    Settings().verbose('whoami: $user');
    return user;
  }

  bool get isSudo => !Settings().isWindows && env['SUDO_USER'] != null;

  String privilegesRequiredMessage(String app) {
    return 'Please run with: sudo $app';
  }

  bool install({bool installDart = false}) {
    if (Platform.isLinux) {
      return LinuxDCliInstaller().install(installDart: installDart);
    } else {
      return MacOsxDCliInstaller().install(installDart: installDart);
    }
  }

  /// at this point no posix system has any preconditions.
  String checkInstallPreconditions() => null;
}
