import 'dart:io';

class DShellPaths {
  static DShellPaths _self;

  String dshellName;
  String dshellInstallName;
  String dshellCompleteName;

  factory DShellPaths() {
    _self ??= DShellPaths.internal();
    return _self;
  }

  DShellPaths.internal() {
    if (Platform.isWindows) {
      dshellName = 'dshell.bat';
      dshellInstallName = 'dshell_install.bat';
      dshellCompleteName = 'dshell_complete.bat';
    } else {
      dshellName = 'dshell';
      dshellInstallName = 'dshell_install';
      dshellCompleteName = 'dshell_complete';
    }
  }
}
