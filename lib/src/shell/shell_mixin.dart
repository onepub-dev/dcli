import 'dart:io';

import '../../dshell.dart';
import 'shell.dart';

mixin ShellMixin implements Shell {
  @override
  bool operator ==(covariant Shell other) {
    return name == other.name;
  }

  /// Attempts to determine obtain the shell name from the SHELL environment variable.
  /// This will only work on posix systems.
  /// For Windows systems we will return null.
  static String loginShell() {
    if (Platform.isWindows) return null;
    return basename(env('SHELL'));
  }

  @override
  int get hashCode => name.hashCode;

  @override
  bool matchByName(String name) {
    return this.name == name.toLowerCase();
  }
}
