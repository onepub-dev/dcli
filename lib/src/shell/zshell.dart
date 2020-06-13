import 'posix_mixin.dart';

import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dshell needs to interact with the Zsh shell.
class ZshShell with ShellMixin, PosixMixin {
  /// Name of the shell
  static const String shellName = 'zsh';

  @override
  bool get isCompletionSupported => false;

  @override
  bool get isCompletionInstalled => false;

  @override
  void installTabCompletion() {
    throw UnimplementedError();
  }

  @override
  String get name => shellName;

  @override
  bool operator ==(covariant ZshShell other) {
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String get startScriptName {
    return '.zshrc';
  }
}
