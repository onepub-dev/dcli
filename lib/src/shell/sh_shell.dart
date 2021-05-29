import 'posix_shell.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class ShShell with ShellMixin, PosixShell {
  /// Attached to the Sh shell with the given pid.
  ShShell.withPid(this.pid);

  /// Name of the shell
  static const String shellName = 'sh';

  @override
  final int? pid;

  @override
  bool get isCompletionSupported => false;

  @override
  bool get isCompletionInstalled {
    // ignore: only_throw_errors
    throw UnimplementedError;
  }

  @override
  void installTabCompletion({bool quiet = false}) {
    // ignore: only_throw_errors
    throw UnimplementedError;
  }

  @override
  String get name => shellName;

  @override
  bool get hasStartScript => false;

  @override
  String get startScriptName {
    // ignore: only_throw_errors
    throw UnimplementedError;
  }

  @override
  String get pathToStartScript {
    // ignore: only_throw_errors
    throw UnimplementedError;
  }

  @override
  bool addToPATH(String path) => false;

  @override
  void addFileAssocation(String dcliPath) {
    /// no op
  }
}
