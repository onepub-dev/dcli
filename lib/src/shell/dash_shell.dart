import 'posix_mixin.dart';

import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dshell needs to interact with the Bash shell.

class DashShell with ShellMixin, PosixMixin {
  /// Name of the shell
  static const String shellName = 'dash';

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => shellName;

  @override
  String get startScriptName {
    return '.dashrc';
  }

   @override
  bool get hasStartScript => true;

  @override
  void installTabCompletion() {
    throw UnimplementedError();
  }
}
