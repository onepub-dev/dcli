/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:path/path.dart';
import 'package:scope/scope.dart';
import 'package:win32/win32.dart';

import '../../dcli.dart';
import '../../windows.dart';
import '../version/version.g.dart';

///
/// Installs dart on an apt base system.abstract
///

class WindowsDCliInstaller {
  /// returns true if it needed to install dart.
  /// @Throwing(ArgumentError)
  /// @Throwing(MissingDependencyException)
  Future<bool> install({bool installDart = true}) async {
    var installedDart = false;

    if (installDart) {
      installedDart = await _installDart();
    }

    Env().appendToPATH(Settings().pathToDCliBin);

    // update the windows registry so the change sticks.
    final path = regGetExpandString(HKEY_CURRENT_USER, 'Environment', 'Path');

    if (!path.contains(Settings().pathToDCliBin)) {
      regAppendToPath(Settings().pathToDCliBin);
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

  /// @Throwing(ArgumentError)
  Future<bool> _installDart() async {
    var installedDart = false;

    // first check that dart isn't already installed
    if (DartSdk().pathToDartExe == null) {
      print('Installing Dart');

      const defaultDartToolDir = r'C:\tools\dart-sdk';

      final dartToolDir = await DartSdk()
          .installFromArchive(defaultDartToolDir, askUser: false);

      /// add the dartsdk path to the windows path.
      Env().appendToPATH(join(dartToolDir, 'bin'));
      Env().appendToPATH(PubCache().pathToBin);

      print('Installed dart to: $dartToolDir');

      installedDart = true;
    } else {
      // nothing to do dart is already installed.
      verbose(
        () => "Found dart at: ${which('dart').path} "
            'and as such will not install dart.',
      );
    }

    return installedDart;
  }
}

// chocolaty for windows installs.
// if (which('choco').notfound) {
//         printerr(
//             "DCli requires the 'Chocolatey' package manager to be
//  installed to install dart");
//         printerr('Install Chocolatey and then try again');
//         throw InstallException('The Chocolatey package manager was
//  not found');
//       }

// // refer to https://github.com/dart-lang/site-www/issues/1073
// 'choco install dart-sdk'.run;
// installedDart = true;
// // does this work.
// 'refreshenv'.run;
// // this may be useful
// // https://github.com/chocolatey/choco/wiki/HelpersInstallChocolateyEnvironmentVariable
