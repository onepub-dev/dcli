import 'dart:io';

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

  String? get loggedInUser {
    var user = _whoami();
    if (user == 'root') {
      user = env['SUDO_USER'] ?? 'root';
    }
    Settings().verbose('loggedInUser: $user');
    return user;
  }

  String? _whoami() {
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
  String? checkInstallPreconditions() => null;
}
