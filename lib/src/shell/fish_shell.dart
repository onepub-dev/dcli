import 'posix_mixin.dart';

import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Zsh shell.
class FishShell with ShellMixin, PosixMixin {
  /// Name of the shell
  static const String shellName = 'fish';

  @override
  final int pid;
  FishShell.withPid(this.pid);

  @override
  bool get isCompletionSupported => false;

  @override
  bool get isCompletionInstalled => false;

  @override
  void installTabCompletion({bool quiet = false}) {
    throw UnimplementedError();
  }

  @override
  String get name => shellName;

  @override
  bool operator ==(covariant FishShell other) {
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String get startScriptName {
    throw UnimplementedError;
  }

  @override
  bool get hasStartScript => false;
}
