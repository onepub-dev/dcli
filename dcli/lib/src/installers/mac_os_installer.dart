/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:path/path.dart';
import 'package:scope/scope.dart';

import '../../dcli.dart';
import '../version/version.g.dart';

///
/// Installs dart on an apt base system.abstract
///

class MacOSDCliInstaller {
  /// returns true if it needed to install dart.
  bool install({required bool installDart}) {
    var installedDart = false;

    if (installDart) {
      installedDart = _installDart();
    }

    // now activate dcli.
    // ignore: invalid_use_of_visible_for_testing_member
    if (Scope.hasScopeKey(installFromSourceKey) &&
        // If we get called in a unit test
        // ignore: invalid_use_of_visible_for_testing_member
        Scope.use(installFromSourceKey)) {
      // If we are called from a unit test we do it from source
      PubCache().globalActivateFromSource(
          join(DartProject.self.pathToProjectRoot, '..', 'dcli_sdk'));
    } else {
      /// activate from pub.dev
      PubCache().globalActivate('dcli_sdk', version: packageVersion);
    }

    return installedDart;
  }

  bool _installDart() {
    // first check that dart isn't already installed
    if (DartSdk().pathToDartExe != null) {
      // nothing to do, dart is already installed.
      verbose(
        () => "Found dart at: ${which('dart').path} and "
            'as such will not install dart.',
      );
      return false;
    }

    print('You must first install dart.');
    print('See the install instructions at: https://dart.dev/get-dart');

    print('PATH:$PATH');

    throw InstallException('You must first install Dart');
  }
}
