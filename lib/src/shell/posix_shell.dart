import 'dart:io';

import 'package:posix/posix.dart';

import '../../dcli.dart';
import '../installers/linux_installer.dart';
import '../installers/macosx_installer.dart';

/// Provides a number of helper functions
/// for posix based shells.
///
/// You would normally access these methods via:
///
/// ```dart
/// Shell.current;
/// ```
///
/// Occasionally you might need to access some posix specific
/// functionality in which case (assuming you are running a posix shell)
/// you can use:
///
/// ```dart
/// (Shell.current as PosixShell);
/// ```
mixin PosixShell {
  /// True if the processes effictive uid is root.
  bool get isPrivilegedUser {
    final euid = geteuid();
    Settings().verbose('isPrivilegedUser: euid=$euid');
    return euid == 0;
    // final user = _whoami();
    // final privileged = user == 'root';
    // Settings().verbose('isPrivilegedUser: $privileged');
    // return privileged;
  }

  /// True if the processes real uid is root.
  bool get isPrivilegedProcess {
    final uid = getuid();
    Settings().verbose('isPrivilegedProcess: uid=$uid');
    return uid == 0;
  }

  String get loggedInUser {
    var user = _whoami();
    if (user == 'root') {
      user = env['SUDO_USER'] ?? 'root';
    }
    Settings().verbose('loggedInUser: $user');
    return user;
  }

  /// Attempts to retrive the logged in user's home directory.
  ///
  /// This is intended when a script is run as sudo and we need
  /// to get the home directory of the original user.
  String get loggedInUsersHome {
    final user = loggedInUser;

    final parts = 'getent passwd $user'.firstLine.split(':');

    final pathToHome = parts[5];

    return pathToHome;
  }

  String _whoami() {
    String user;
    if (isPosixSupported) {
      try {
        user = getlogin();
      } on PosixException catch (e) {
        if (e.code == ENXIO) {
          // no controlling terminal so we must be root.
          user = 'root';
        }
      }
    }

    /// fall back to whoami if nothing else works.
    user ??= 'whoami'.firstLine;
    Settings().verbose('whoami: $user');
    return user;
  }

  /// revert uid and gid to original user's id's
  void releasePrivileges() {
    if (Shell.current.isPrivilegedUser) {
      final sUID = env['SUDO_UID'];
      final gUID = env['SUDO_GID'];

      // convert id's to integers.
      final originalUID = sUID != null ? int.tryParse(sUID) ?? 0 : 0;
      final originalGID = gUID != null ? int.tryParse(gUID) ?? 0 : 0;

      setegid(originalGID);
      seteuid(originalUID);
    }
  }

  /// Run [privilegedCallback] with root UID and gid
  void withPrivileges(RunPrivileged privilegedCallback) {
    if (!Shell.current.isPrivilegedProcess) {
      throw ShellException(
          'You can only use withPrivileges when running as a privileged user.');
    }
    final privileged = geteuid() == 0;

    if (!privileged) {
      setegid(0);
      seteuid(0);
    }

    privilegedCallback();

    /// If the code was originally running privileged then
    /// we leave it as it was.
    if (!privileged) {
      releasePrivileges();
    }
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
