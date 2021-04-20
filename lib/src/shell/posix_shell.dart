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

  /// Returns true if running a privileged action would
  /// cause a password to be requested.
  ///
  /// Linux/OSX: will return true if the sudo password is not currently
  /// cached and we are not already running as a privileged user.
  ///
  /// Windows: This will always return false as Windows is never
  /// able to escalate privileges.
  bool get isPrivilegedPasswordRequired {
    if (isPrivilegedUser) {
      print('user is privileged');
      return false;
    }
    final response = 'sudo -nv'.toList(nothrow: true);

    print('sudo -nv return $response');
    var result =
        response.isNotEmpty && response.first == 'sudo: a password is required';
    print('password $result');
    return result;
  }

  /// True if the processes real uid is root.
  bool get isPrivilegedProcess {
    final uid = getuid();
    Settings().verbose('isPrivilegedProcess: uid=$uid');
    return uid == 0;
  }

  /// returns the username of the logged in user.
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

    final parts = 'getent passwd $user'.firstLine!.split(':');

    final pathToHome = parts[5];

    return pathToHome;
  }

  String _whoami() {
    String? user;
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
    return user!;
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

  /// Returns true if we are currently running under sudo.
  bool get isSudo => !Settings().isWindows && env['SUDO_USER'] != null;

  /// The message used during installation if it needs to be run with sudo.
  String privilegesRequiredMessage(String app) => 'Please run with: sudo $app';

  /// Install dart/dcli
  bool install({bool installDart = false}) {
    if (Platform.isLinux) {
      return LinuxDCliInstaller().install(installDart: installDart);
    } else {
      return MacOsxDCliInstaller().install(installDart: installDart);
    }
  }

  /// at this point no posix system has any preconditions.
  String? checkInstallPreconditions() => null;
}
