import '../../dcli.dart';
import '../installers/windows_installer.dart';
import '../script/commands/install.dart';

mixin WindowsMixin {
  String checkInstallPreconditions() {
//     if (!inDeveloperMode()) {
//       return '''
// You must be running in Windows Developer Mode to install DCli.
// Read additional details here: https://bsutton.gitbook.io/dcli/getting-started/installing-on-windows''';
//     }
    return null;
  }

  /// Windows 10+ has a developer mode that needs to be enabled to create symlinks without escalated prividedges.
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

  bool get isPrivilegedUser {
    final currentPrincipal =
        'New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())'
            .firstLine;
    Settings().verbose('currentPrinciple: $currentPrincipal');
    final isPrivileged =
        '$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)'
            .firstLine;
    Settings().verbose('isPrivileged: $isPrivileged');

    return isPrivileged.toLowerCase() == 'true';
  }

  bool install({bool installDart = true}) {
    return WindowsDCliInstaller().install(installDart: installDart);
  }

  String privilegesRequiredMessage(String app) {
    return 'You need to be a privileged user to run $app';
  }

  String get loggedInUser => env['USERNAME'];

  bool get isSudo => false;
}
