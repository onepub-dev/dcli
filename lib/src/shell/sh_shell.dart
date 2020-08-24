import '../../dcli.dart';
import 'posix_mixin.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class ShShell with ShellMixin, PosixMixin {
  /// Name of the shell
  static const String shellName = 'sh';

  @override
  final int pid;
  ShShell.withPid(this.pid);

  @override
  String get pathToStartScript {
    return join(HOME, startScriptName);
  }

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
  String get startScriptName {
    throw UnimplementedError;
  }

  @override
  bool get hasStartScript => false;
}
