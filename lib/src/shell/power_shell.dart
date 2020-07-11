import '../../dshell.dart';
import '../installers/windows_installer.dart';
import '../script/commands/install.dart';
import 'shell_mixin.dart';

/// Windows Power Shell
class PowerShell with ShellMixin {
  /// Name of the shell
  static const String shellName = 'powershell.exe';

  @override
  bool addToPath(String path) {
    /// These need to be run as admin
    /// not working correctly at this point.
    /// Looks like powershell ignores the file association.
    'cmd /c assoc .dart=dshell'.run;
    r'''cmd /c ftype dshell=`"C:\Users\User\dshell`" `"%1`" `"%2`" `"%3`" `"%4`" `"%5`" `"%6`" `"%7`" `"%8`" `"%9`"'''
        .run;
    return true;
  }

  @override
  void installTabCompletion() {
    // not supported.
  }

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => shellName;

  @override
  bool operator ==(covariant PowerShell other) {
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String get startScriptName => throw UnimplementedError;

  @override
  String get startScriptPath => throw UnimplementedError;

  @override
  bool get hasStartScript => false;

  @override
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

  @override
  String get loggedInUser => env('USERNAME');

  @override
  String privilegesRequiredMessage(String app) {
    return 'You need to be a privileged user to run $app';
  }

  @override
  bool install() {
    return WindowsDShellInstaller().install();
  }

  @override
  String checkInstallPreconditions() {
    if (!inDeveloperMode()) {
      return '''You must be running in Windows Developer Mode to install DShell.
Read additional details here: https://github.com/bsutton/dshell/wiki/Installing-DShell#windows''';
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
        'reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v "AllowDevelopmentWithoutDevLicense"'
            .toList(skipLines: 2)
            .first;
    var parts = response.split(r'\s+');
    if (parts.length != 3) {
      throw InstallException('Unable to obtain development mode settings');
    }

    return parts[3] == '0x1';
  }
}
