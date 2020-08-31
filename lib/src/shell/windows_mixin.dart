import '../../dcli.dart';
import '../installers/windows_installer.dart';
import '../script/commands/install.dart';

mixin WindowsMixin {
  String checkInstallPreconditions() {
    if (!inDeveloperMode()) {
      return '''You must be running in Windows Developer Mode to install DCli.
Read additional details here: https://github.com/bsutton/dcli/wiki/Installing-DCli#windows''';
    }
    return null;
  }

  /// Windows 10+ has a developer mode that needs to be enabled to create symlinks without escalated prividedges.
  bool inDeveloperMode() {
    /// Example result:
    /// <blank line>
    /// HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock
    /// AllowDevelopmentWithoutDevLicense    REG_DWORD    0x1

    var response =
        r'reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v "AllowDevelopmentWithoutDevLicense"'
            .toList(runInShell: true, skipLines: 2)
            .first;
    var parts = response.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) {
      throw InstallException('Unable to obtain development mode settings');
    }

    return parts[2] == '0x1';
  }

  bool get isPrivilegedUser {
    var currentPrincipal =
        'New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())'
            .firstLine;
    Settings().verbose('currentPrinciple: $currentPrincipal');
    var isPrivileged =
        '$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)'
            .firstLine;
    Settings().verbose('isPrivileged: $isPrivileged');

    return isPrivileged.toLowerCase() == 'true';
  }

  bool install() {
    return WindowsDCliInstaller().install();
  }

  String privilegesRequiredMessage(String app) {
    return 'You need to be a privileged user to run $app';
  }

  String get loggedInUser => env['USERNAME'];
}
