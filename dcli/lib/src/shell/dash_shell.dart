/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:path/path.dart';

import '../../dcli.dart';
import 'posix_shell.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class DashShell with ShellMixin, PosixShell {
  /// Name of the shell
  static const shellName = 'dash';

  @override
  final int? pid;

  /// Attached to the Dash shell with the given pid.
  DashShell.withPid(this.pid);

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => shellName;

  /// Throws [UnimplementedError].
  @override
  void installTabCompletion({bool quiet = false}) {
    throw UnimplementedError();
  }

  /// Returns true if this shell supports
  /// modifying the shell's PATH
  @override
  bool get canModifyPath => false;

  /// Throws [UnsupportedError].
  @override
  @Deprecated('Use appendToPATH')
  bool addToPATH(String path) =>
      throw UnsupportedError('Not supported in dash');

  /// Throws [UnsupportedError].
  @override
  bool appendToPATH(String path) =>
      throw UnsupportedError('Not supported in dash');

  /// Throws [UnsupportedError].
  @override
  bool prependToPATH(String path) =>
      throw UnsupportedError('Not supported in dash');

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get hasStartScript => env['ENV'] != null;

  @override
  String get startScriptName => basename(env['ENV']!);

  @override
  String get pathToStartScript => env['ENV']!;

  @override
  void addFileAssocation(String dcliPath) {
    /// no op
  }
}
