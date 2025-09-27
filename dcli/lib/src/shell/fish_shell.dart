/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'posix_shell.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Zsh shell.
class FishShell with ShellMixin, PosixShell {
  /// Name of the shell
  static const shellName = 'fish';

  @override
  final int? pid;

  /// Attached to the Fish shell with the given pid.
  FishShell.withPid(this.pid);

  @override
  String get name => shellName;

  @override
  bool operator ==(covariant FishShell other) => name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  bool get hasStartScript => true;

  @override
  String get startScriptName => 'config.fish';

  @override
  String get pathToStartScript => '~/.config/fish/config.fish';

  @override
  bool get isCompletionSupported => false;

  @override
  bool get isCompletionInstalled => false;

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
      throw UnsupportedError('Not supported in fish');

  @override
  bool appendToPATH(String path) =>
      throw UnsupportedError('Not supported in fish');

  @override
  bool prependToPATH(String path) =>
      throw UnsupportedError('Not supported in fish');

  @override
  void addFileAssocation(String dcliPath) {
    /// no op
  }
}
