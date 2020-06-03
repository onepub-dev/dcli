import '../../dshell.dart';

/// Windows Power Shell
class PowerShell implements Shell {
  @override
  bool addToPath(String path) {
    // TODO: implement addToPath

    /// These need to be run as admin
    /// not working correctly at this point.
    /// Looks like powershell ignores the file association.
    'cmd /c assoc .dart=dshell'.run;
    r'''cmd /c ftype dshell=`"C:\Users\User\dshell`" `"%1`" `"%2`" `"%3`" `"%4`" `"%5`" `"%6`" `"%7`" `"%8`" `"%9`"'''
        .run;
    return false;
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
  String get name => 'powershell';

  @override
  // TODO: implement startScriptName
  String get startScriptName => null;

  @override
  // TODO: implement startScriptPath
  String get startScriptPath => null;

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
}
