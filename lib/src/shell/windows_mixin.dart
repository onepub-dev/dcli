import 'package:win32/win32.dart';

import '../../dcli.dart';
import '../installers/windows_installer.dart';
import '../platform/windows/registry.dart';

/// Common code for Windows shells.
mixin WindowsMixin {
  /// Check if the shell has any notes re: pre-isntallation conditions.
  String? checkInstallPreconditions() => null;

  /// Windows 10+ has a developer mode that needs to be enabled to create
  ///  symlinks without escalated prividedges.
  /// For details on enabling dev mode on windows see:
  /// https://bsutton.gitbook.io/dcli/getting-started/installing-on-windows
  bool inDeveloperMode() {
    final response = regGetDWORD(
        HKEY_LOCAL_MACHINE,
        r'SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock',
        'AllowDevelopmentWithoutDevLicense');

    return response == 1;
  }

  /// Called to install the windows specific dart/dcli components.
  bool install({bool installDart = true}) =>
      WindowsDCliInstaller().install(installDart: installDart);

  ///
  String privilegesRequiredMessage(String app) =>
      'You need to be an Administrator to run $app';

  /// Returns true if running a privileged action would
  /// cause a password to be requested.
  ///
  /// Linux/OSX: will return true if the sudo password is not currently
  /// cached and we are not already running as a privileged user.
  ///
  /// Windows: This will always return false as Windows is never
  /// able to escalate privileges.
  bool get isPrivilegedPasswordRequired => false;

  ///
  String? get loggedInUser => env['USERNAME'];

  /// NO OP under windows
  void releasePrivileges() {
    /// NO OP under windows as its not possible and not needed.
  }

  /// NO OP under windows
  void restorePrivileges() {
    /// NO OP under windows as its not possible and not needed.
  }

  /// Run [action] with root UID and gid
  void withPrivileges(RunPrivileged action) {
    if (!Shell.current.isPrivilegedUser) {
      throw ShellException(
          'You can only use withPrivileges when running as a privileged user.');
    }
    action();
  }

  /// On Windows this is always false.
  bool get isSudo => false;
}
