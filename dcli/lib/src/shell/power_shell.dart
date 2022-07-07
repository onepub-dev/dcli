/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'shell_mixin.dart';
import 'windows_mixin.dart';

/// Windows Power Shell
class PowerShell with WindowsMixin, ShellMixin {
  /// Attached to the Powershell shell with the given pid.
  PowerShell.withPid(this.pid);

  /// Name of the shell
  static const String shellName = 'powershell.exe';

  @override
  final int? pid;

  @override
  bool addToPATH(String path) => true;

  @override
  void installTabCompletion({bool quiet = false}) {
    // not supported.
  }

  @override
  void addFileAssocation(String dcliPath) {
    super.addFileAssociation(dcliPath);
  }

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => shellName;

  @override
  bool operator ==(covariant PowerShell other) => name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  bool get hasStartScript => false;

  @override
  // ignore: only_throw_errors
  String get startScriptName => throw UnimplementedError;

  @override
  // ignore: only_throw_errors
  String get pathToStartScript => throw UnimplementedError;
}
