import 'dart:io';

import '../../dcli.dart';
import 'shell.dart';

mixin ShellMixin implements Shell {
  @override
  bool operator ==(covariant Shell other) {
    return name == other.name;
  }

  /// Attempts to determine the shell name from the SHELL environment variable.
  /// This will only work on posix systems.
  /// For Windows systems we will return null.
  static String loginShell() {
    var shell = env('SHELL');
    if (Platform.isWindows || shell == null) return null;

    return basename(env('SHELL'));
  }

  @override
  int get hashCode => name.hashCode;

  @override
  bool matchByName(String name) {
    return this.name == name.toLowerCase();
  }
}
