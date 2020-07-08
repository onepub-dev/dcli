import '../../dshell.dart';
import 'shell_mixin.dart';

/// Windows Power Shell
class PowerShell with ShellMixin {
  /// Name of the shell
  static const String shellName = 'powershell';

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
    // TODO: implement install
    throw UnimplementedError();
  }
}
