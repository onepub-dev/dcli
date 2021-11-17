import '../../dcli.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Zsh shell.
class ZshShell with ShellMixin, PosixShell {
  /// Attached to the Zsh shell with the given pid.
  ZshShell.withPid(this.pid);

  /// Name of the shell
  static const String shellName = 'zsh';

  @override
  final int? pid;

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
  bool operator ==(covariant ZshShell other) => name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  bool get hasStartScript => true;

  @override
  String get startScriptName => '.zshrc';

  @override
  String get pathToStartScript => join(HOME, startScriptName);

  @override
  @Deprecated('Use appendToPATH')
  bool addToPATH(String path) => false;

  @override
  bool appendToPATH(String path) => false;

  @override
  bool prependToPATH(String path) => false;

  @override
  void addFileAssocation(String dcliPath) {
    /// no op
  }
}
