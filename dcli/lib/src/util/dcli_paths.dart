/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import '../functions/which.dart';

import '../settings.dart';

/// platform specific names of the dcli commands.
class DCliPaths {
  ///
  factory DCliPaths() => _self ??= DCliPaths._internal();

  DCliPaths._internal() {
    if (Settings().isWindows) {
      dcliName = 'dcli.bat';
      dcliInstallName = 'dcli_install.bat';
      dcliCompleteName = 'dcli_complete.bat';
    } else {
      dcliName = 'dcli';
      dcliInstallName = 'dcli_install';
      dcliCompleteName = 'dcli_complete';
    }
  }

  static DCliPaths? _self;

  /// platform specific name of the dcli command
  late final String dcliName;

  /// platform specific name of the dcli install command
  late final String dcliInstallName;

  /// platform specific name of the dcli auto complete command
  late final String dcliCompleteName;

  /// Returns the path to the DCli executable.
  /// Returns null if DCli is not on the path.
  String? get pathToDCli {
    final result = which(dcliName);

    if (result.found) {
      return result.path;
    }
    return null;
  }
}
