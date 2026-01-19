/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:path/path.dart';

import '../../dcli.dart';
import '../../posix.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class AshShell with ShellMixin, PosixShell {
  @override
  final int? pid;

  /// Name of the shell
  static const shellName = 'ash';

  /// Attached to an Ash shell with the give pid.
  AshShell.withPid(this.pid);

  @override
  bool get isCompletionSupported => false;

  // adds bash cli completion for dcli
  // by adding a 'complete' command to ~/.bashrc
    /// Throws [UnimplementedError].
  /// @Throwing(UnimplementedError)
  @override
  void installTabCompletion({bool? quiet = false}) {
    throw UnimplementedError();
  }

  @override
  String get name => shellName;

  /// Returns true if this shell supports
  /// modifying the shell's PATH
  @override
  bool get canModifyPath => false;

    /// Throws [UnsupportedError].
  /// @Throwing(UnsupportedError)
  @override
  @Deprecated('Use appendToPATH')
  bool addToPATH(String path) => throw UnsupportedError('Not supported in ash');

    /// Throws [UnsupportedError].
  /// @Throwing(UnsupportedError)
  @override
  bool appendToPATH(String path) =>
      throw UnsupportedError('Not supported in ash');

    /// Throws [UnsupportedError].
  /// @Throwing(UnsupportedError)
  @override
  bool prependToPATH(String path) =>
      throw UnsupportedError('Not supported in ash');

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get hasStartScript => true;

  @override
  String get startScriptName => '.ashrc';

        /// @Throwing(ArgumentError)
  @override
  String get pathToStartScript => join(HOME, startScriptName);

  @override
  void addFileAssocation(String dcliPath) {
    /// no op
  }
}
