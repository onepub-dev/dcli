import '../../dcli.dart';
import 'shell_mixin.dart';
import 'windows_mixin.dart';

/// Windows Power Shell
class PowerShell with WindowsMixin, ShellMixin {
  /// Attached to the Powershell shell with the given pid.
  PowerShell.withPid(this.pid);

  /// Name of the shell
  static const String shellName = 'powershell.exe';

  @override
  final int? pid;

  @override
  bool addToPATH(String path) => true;

  @override
  void addFileAssocation(String dcliPath) {
    /// These need to be run as admin
    /// not working correctly at this point.
    /// Looks like powershell ignores the file association.
    /// We need to run as a priviliged user for this to work.
    'cmd /c assoc .dart=dcli'.run;
    '''cmd /c ftype dcli="${DCliPaths().pathToDCli}" "%1" "%2" "%3" "%4" "%5" "%6" "%7" "%8" "%9"'''
        .run;
  }

  @override
  void installTabCompletion({bool quiet = false}) {
    // not supported.
  }

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => shellName;

  @override
  bool operator ==(covariant PowerShell other) => name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  bool get hasStartScript => false;

  @override
  // ignore: only_throw_errors
  String get startScriptName => throw UnimplementedError;

  @override
  // ignore: only_throw_errors
  String get pathToStartScript => throw UnimplementedError;
}
