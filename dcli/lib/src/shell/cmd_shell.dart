/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'shell_mixin.dart';
import 'windows_mixin.dart';

/// Windows Power Shell
class CmdShell with WindowsMixin, ShellMixin {
  /// Name of the shell
  static const shellName = 'cmd.exe';

  @override
  final int? pid;

  /// Attached to a command shell with the given
  CmdShell.withPid(this.pid);

  @override
  bool addToPATH(String path) => true;

  @override
  void addFileAssocation(String dcliPath) {
    super.addFileAssociation(dcliPath);
  }

  @override
  void installTabCompletion({bool quiet = false}) {
    // not supported.
  }

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => shellName;

  @override
  bool operator ==(covariant CmdShell other) => name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  bool get hasStartScript => false;

  @override
  // good enough
  // ignore: only_throw_errors
  String get startScriptName => throw UnimplementedError;

  @override
  // good enough
  // ignore: only_throw_errors
  String get pathToStartScript => throw UnimplementedError;
}
