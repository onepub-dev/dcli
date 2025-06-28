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
  /// Attached to the Dash shell with the given pid.
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

  /// Returns true if this shell supports
  /// modifying the shell's PATH
  @override
  bool get canModifyPath => false;

  @override
  @Deprecated('Use appendToPATH')
  bool addToPATH(String path) =>
      throw UnsupportedError('Not supported in dash');

  @override
  bool appendToPATH(String path) =>
      throw UnsupportedError('Not supported in dash');

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
