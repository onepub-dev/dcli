import 'posix_shell.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class ShShell with ShellMixin, PosixShell {
  ShShell.withPid(this.pid);

  /// Name of the shell
  static const String shellName = 'sh';

  @override
  final int? pid;

  @override
  bool get isCompletionSupported => false;

  @override
  bool get isCompletionInstalled {
    throw UnimplementedError;
  }

  @override
  void installTabCompletion({bool quiet = false}) {
    throw UnimplementedError;
  }

  @override
  String get name => shellName;

  @override
  bool get hasStartScript => false;

  @override
  String get startScriptName {
    throw UnimplementedError;
  }

  @override
  String get pathToStartScript {
    throw UnimplementedError;
  }

  @override
  bool addToPATH(String path) => false;
}
