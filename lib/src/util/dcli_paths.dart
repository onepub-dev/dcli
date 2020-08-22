import 'dart:io';

/// platform specific names of the dcli commands.
class DCliPaths {
  static DCliPaths _self;

  /// platform specific name of the dcli command
  String dcliName;

  /// platform specific name of the dcli install command
  String dcliInstallName;

  /// platform specific name of the dcli auto complete command
  String dcliCompleteName;

  ///
  factory DCliPaths() {
    _self ??= DCliPaths._internal();
    return _self;
  }

  DCliPaths._internal() {
    if (Platform.isWindows) {
      dcliName = 'dcli.bat';
      dcliInstallName = 'dcli_install.bat';
      dcliCompleteName = 'dcli_complete.bat';
    } else {
      dcliName = 'dcli';
      dcliInstallName = 'dcli_install';
      dcliCompleteName = 'dcli_complete';
    }
  }
}
