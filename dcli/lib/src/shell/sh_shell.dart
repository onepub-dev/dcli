/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'posix_shell.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class ShShell with ShellMixin, PosixShell {
  /// Attached to the Sh shell with the given pid.
  ShShell.withPid(this.pid);

  /// Name of the shell
  static const String shellName = 'sh';

  @override
  final int? pid;

  @override
  bool get isCompletionSupported => false;

  @override
  bool get isCompletionInstalled {
    // ignore: only_throw_errors
    throw UnimplementedError;
  }

  @override
  void installTabCompletion({bool quiet = false}) {
    // ignore: only_throw_errors
    throw UnimplementedError;
  }

  @override
  String get name => shellName;

  @override
  bool get hasStartScript => false;

  @override
  String get startScriptName {
    // ignore: only_throw_errors
    throw UnimplementedError;
  }

  @override
  String get pathToStartScript {
    // ignore: only_throw_errors
    throw UnimplementedError;
  }

  /// Returns true if this shell supports
  /// modifying the shell's PATH
  @override
  bool get canModifyPath => false;

  @override
  @Deprecated('Use appendToPATH')
  bool addToPATH(String path) => throw UnsupportedError('Not supported in sh');

  @override
  bool appendToPATH(String path) =>
      throw UnsupportedError('Not supported in sh');

  @override
  bool prependToPATH(String path) =>
      throw UnsupportedError('Not supported in sh');
  @override
  void addFileAssocation(String dcliPath) {
    /// no op
  }

  @override
  String get installInstructions => r'''
Run:
sudo env PATH="$PATH" dcli install
''';
}
