/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'posix_shell.dart';

import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Zsh shell.
class FishShell with ShellMixin, PosixShell {
  /// Attached to the Fish shell with the given pid.
  FishShell.withPid(this.pid);

  /// Name of the shell
  static const String shellName = 'fish';

  @override
  final int? pid;

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
