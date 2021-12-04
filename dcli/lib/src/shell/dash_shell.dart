import '../../dcli.dart';
import 'posix_shell.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class DashShell with ShellMixin, PosixShell {
  /// Attached to the Dash shell with the given pid.
  DashShell.withPid(this.pid);

  /// Name of the shell
  static const String shellName = 'dash';

  @override
  final int? pid;

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => shellName;

  @override
  void installTabCompletion({bool quiet = false}) {
    throw UnimplementedError();
  }

  @Deprecated('User appendToPATH')
  @override
  bool addToPATH(String path) => appendToPATH(path);

  @override
  bool appendToPATH(String path) => false;

  @override
  bool prependToPATH(String path) => false;

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get hasStartScript => env['ENV'] != null;

  @override
  String get startScriptName => basename(env['ENV']!);

  @override
  String get pathToStartScript => env['ENV']!;

  @override
  void addFileAssocation(String dcliPath) {
    /// no op
  }
}
