import 'dart:io';

/// platform specific names of the dshell commands.
class DShellPaths {
  static DShellPaths _self;

  /// platform specific name of the dshell command
  String dshellName;

  /// platform specific name of the dshell install command
  String dshellInstallName;

  /// platform specific name of the dshell auto complete command
  String dshellCompleteName;

  ///
  factory DShellPaths() {
    _self ??= DShellPaths._internal();
    return _self;
  }

  DShellPaths._internal() {
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
