/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import '../../dcli.dart';
import '../../posix.dart';
import 'shell_mixin.dart';

/// Provides a number of helper functions
/// when dcli needs to interact with the Bash shell.

class AshShell with ShellMixin, PosixShell {
  /// Attached to an Ash shell with the give pid.
  AshShell.withPid(this.pid);

  @override
  final int? pid;

  /// Name of the shell
  static const String shellName = 'ash';

  @override
  bool get isCompletionSupported => false;

  // adds bash cli completion for dcli
  // by adding a 'complete' command to ~/.bashrc
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

  @override
  @Deprecated('Use appendToPATH')
  bool addToPATH(String path) => throw UnsupportedError('Not supported in ash');

  @override
  bool appendToPATH(String path) =>
      throw UnsupportedError('Not supported in ash');

  @override
  bool prependToPATH(String path) =>
      throw UnsupportedError('Not supported in ash');

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get hasStartScript => true;

  @override
  String get startScriptName => '.ashrc';

  @override
  String get pathToStartScript => join(HOME, startScriptName);

  @override
  void addFileAssocation(String dcliPath) {
    /// no op
  }
}
