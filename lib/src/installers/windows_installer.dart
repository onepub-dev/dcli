import 'dart:io';

import '../../dshell.dart';
import '../functions/env.dart';
import '../script/dart_sdk.dart';
import '../util/pub_cache.dart';

///
/// Installs dart on an apt base system.abstract
///

class WindowsDShellInstaller {
  /// returns true if it needed to install dart.
  bool install() {
    var installedDart = false;
    // first check that dart isn't already installed
    if (which('dart').firstLine == null) {
      print('Installing Dart');

      var defaultDartToolDir = r"C:\tools\dart-sdk";

      var dartToolDir =
          DartSdk().installFromArchive(defaultDartToolDir, askUser: false);

      /// add the dartsdk path to the windows path.
      Env().pathPutIfAbsent(join(dartToolDir, 'bin'));
      Env().pathPutIfAbsent(PubCache().binPath);
      Env().pathPutIfAbsent(Settings().dshellBinPath);

      'setx PATH "%PATH%;${PATH.join(Platform.pathSeparator)}"'.run;

      print('Installed dart to: $dartToolDir');

      installedDart = true;
    } else {
      // nothing to do dart is already installed.
      Settings().verbose(
          "Found dart at: ${which('dart').firstLine} and as such will not install dart.");
    }
    '${DartSdk().pubPath} global activate dshell'.run;

    return installedDart;
  }
}

// chocolaty for windows installs.
// if (which('choco').firstLine == null) {
//         printerr(
//             "DShell requires the 'Chocolatey' package manager to be installed to install dart");
//         printerr('Please install Chocolatey and then try again');
//         throw InstallException('The Chocolatey package manager was not found');
//       }

// // refer to https://github.com/dart-lang/site-www/issues/1073
// 'choco install dart-sdk'.run;
// installedDart = true;
// // does this work.
// 'refreshenv'.run;
// // this may be useful
// // https://github.com/chocolatey/choco/wiki/HelpersInstallChocolateyEnvironmentVariable
