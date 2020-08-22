import 'posix_mixin.dart';

import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class AshShell with ShellMixin, PosixMixin {
  @override
  final int pid;
  AshShell.withPid(this.pid);

  /// Name of the shell
  static const String shellName = 'ash';

  @override
  bool get isCompletionSupported => false;

  // adds bash cli completion for dcli
  // by adding a 'complete' command to ~/.bashrc
  @override
  void installTabCompletion({bool quiet = false}) {
    throw UnimplementedError();
  }

  @override
  String get name => shellName;

  @override
  String get startScriptName {
    return '.ashrc';
  }

  @override
  bool get hasStartScript => true;
}
