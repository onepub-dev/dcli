import 'package:dcli/src/functions/env.dart';
import 'package:path/path.dart';

import 'posix_shell.dart';

import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class DashShell with ShellMixin, PosixShell {
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

  @override
  bool addToPATH(String path) => false;

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get hasStartScript => env['ENV'] != null;

  @override
  String get startScriptName => basename(env['ENV']!);

  @override
  String get pathToStartScript => env['ENV']!;
}
