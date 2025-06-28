/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:path/path.dart';

import '../../dcli.dart';

/// Base class containing common code for all Shell implementations.
mixin ShellMixin implements Shell {
  @override
  bool operator ==(covariant Shell other) => name == other.name;

  /// Attempts to determine the shell name from the SHELL environment variable.
  /// This will only work on posix systems.
  /// For Windows systems we will return null.
  static String? loginShell() {
    final shell = env['SHELL'];
    if (Settings().isWindows || shell == null) {
      return null;
    }

    return basename(env['SHELL']!);
  }

  @override
  int get hashCode => name.hashCode;

  @override
  bool matchByName(String name) => this.name == name.toLowerCase();
}
