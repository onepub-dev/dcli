import '../../dcli.dart';
import '../settings.dart';

///
/// Installs dart on an apt base system.abstract
///

class MacOsxDCliInstaller {
  /// returns true if it needed to install dart.
  bool install({required bool installDart}) {
    if (installDart) {
      _installDart();
    }

    // TODO(bsutton): I've had to remove this for the moment due to https://github.com/dart-lang/sdk/issues/46255
    // if (which('dart').notfound) {
    //   // The normal dart detection process won't work here
    //   // as dart is not on the path so for the moment we hard code it.
    //   // CONSIDER a way of identifying where dart has been installed to.
    //   '/usr/lib/dart/bin/dart pub global activate dcli'.run;
    // } else {
    //   DartSdk().globalActivate('dcli');
    // }

    // we currently never install dart.
    return false;
  }

  bool _installDart() {
    // first check that dart isn't already installed
    if (DartSdk().pathToDartExe == null) {
      // nothing to do dart is already installed.
      verbose(() => "Found dart at: ${which('dart').path} and "
          'as such will not install dart.');
      return false;
    }

    print('You must first install dart.');
    print('See the install instructions at: https://dart.dev/get-dart');

    return false;
  }
}
