import 'package:path/path.dart';

import '../../dcli.dart';
import 'posix_shell.dart';

import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class AshShell with ShellMixin, PosixShell {
  /// Attached to an Ash shell with the give pid.
  AshShell.withPid(this.pid);

  @override
  final int? pid;

  /// Name of the shell
  static const String shellName = 'ash';

  @override
  bool get isCompletionSupported => false;

  // adds bash cli completion for dcli
  // by adding a 'complete' command to ~/.bashrc
  @override
  void installTabCompletion({bool? quiet = false}) {
    throw UnimplementedError();
  }

  @override
  String get name => shellName;

  @override
  @Deprecated('Use appendToPATH')
  bool addToPATH(String path) => false;
  
  @override
  bool appendToPATH(String path) => false;

  @override
  bool prependToPATH(String path) => false;

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get hasStartScript => true;

  @override
  String get startScriptName => '.ashrc';

  @override
  String get pathToStartScript => join(HOME, startScriptName);

  @override
  void addFileAssocation(String dcliPath) {
    /// no op
  }
}
