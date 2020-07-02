import '../../dshell.dart';
import '../script/dart_sdk.dart';

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

      var defaultDartToolDir = "C:\tools\dart-sdk";

      var dartToolDir = DartSdk().installFromArchive(defaultDartToolDir);

      /// add the dartsdk path to the windows path.
      'setx path "%path%";$dartToolDir'.run;

      /// using the archive would allow us to provide a consistent install experience without requiring
      /// a package manager to be preinstalled.

      // The normal dart detection process won't work here
      // as dart is not on the path so for the moment we force it
      // to the path we just downloaded it to.
      // CONSIDER a way of identifying where dart has been installed to.
      setDartSdkPath(dartToolDir);
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
