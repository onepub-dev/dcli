/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:scope/scope.dart';

import '../../dcli.dart';
import '../commands/install.dart';
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
    if (Scope.hasScopeKey(InstallCommand.activateFromSourceKey) &&
        Scope.use(InstallCommand.activateFromSourceKey) == true) {
      // If we are called from a unit test we do it from source
      PubCache().globalActivateFromSource(DartProject.self.pathToProjectRoot);
    } else {
      /// activate from pub.dev
      PubCache().globalActivate('dcli', version: packageVersion);
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
