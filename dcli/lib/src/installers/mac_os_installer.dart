import '../../dcli.dart';

///
/// Installs dart on an apt base system.abstract
///

class MacOSDCliInstaller {
  /// returns true if it needed to install dart.
  bool install({required bool installDart, bool activate = true}) {
    var installedDart = false;

    if (installDart) {
      installedDart = _installDart();
    }

    // now activate dcli.
    if (activate) {
      PubCache().globalActivate('dcli');
    }

    return installedDart;
  }

  bool _installDart() {
    // first check that dart isn't already installed
    if (DartSdk().pathToDartExe == null) {
      // nothing to do dart is already installed.
      verbose(
        () => "Found dart at: ${which('dart').path} and "
            'as such will not install dart.',
      );
      return false;
    }

    print('You must first install dart.');
    print('See the install instructions at: https://dart.dev/get-dart');

    return false;
  }
}
