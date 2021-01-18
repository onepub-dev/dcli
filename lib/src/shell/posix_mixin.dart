import 'dart:io';

import 'package:posix/posix.dart';

import '../../dcli.dart';
import '../installers/linux_installer.dart';
import '../installers/macosx_installer.dart';

/// Provides a number of helper functions
/// when for posix based shells.
mixin PosixMixin {
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
    if (!Shell.current.isPrivilegedUser) {
      throw ShellException(
          'You can only use withPrivileges when running as a privileged user.');
    }
    final privileged = Shell.current.isPrivilegedUser;

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
