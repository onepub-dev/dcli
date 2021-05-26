

import '../../dcli.dart';
import '../installers/windows_installer.dart';
import '../script/commands/install.dart';

/// Common code for Windows shells.
mixin WindowsMixin {
  /// Check if the shell has any notes re: pre-isntallation conditions.
  String? checkInstallPreconditions() => null;

  /// Windows 10+ has a developer mode that needs to be enabled to create
  ///  symlinks without escalated prividedges.
  /// For details on enabling dev mode on windows see:
  /// https://bsutton.gitbook.io/dcli/getting-started/installing-on-windows
  bool inDeveloperMode() {
    /// Example result:
    /// <blank line>
    /// HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock
    /// AllowDevelopmentWithoutDevLicense    REG_DWORD    0x1
    final response =
        r'reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v "AllowDevelopmentWithoutDevLicense"'
            .toList(runInShell: true, skipLines: 2)
            .first;
    final parts = response.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) {
      throw InstallException('Unable to obtain development mode settings');
    }

    return parts[2] == '0x1';
  }

  /// Called to install the windows specific dart/dcli components.
  bool install({bool installDart = true}) =>
      WindowsDCliInstaller().install(installDart: installDart);

  ///
  String privilegesRequiredMessage(String app) =>
      'You need to be a privileged user to run $app';

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
