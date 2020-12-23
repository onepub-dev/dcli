import '../../dcli.dart';

///
/// Installs dart on an apt base system.abstract
///

class MacOsxDCliInstaller {
  /// returns true if it needed to install dart.
  bool install({bool installDart}) {
    if (installDart) {
      _installDart();
    }

    // The normal dart detection process won't work here
    // as dart is not on the path so for the moment so we hard code it.
    // CONSIDER a way of identifying where dart has been installed to.
    '/usr/lib/dart/bin/dart pub global activate dcli'.run;

    // we currently never install dart.
    return false;
  }

  bool _installDart() {
    // first check that dart isn't already installed
    if (which('dart').found) {
      // nothing to do dart is already installed.
      Settings().verbose(
          "Found dart at: ${which('dart').path} and as such will not install dart.");
      return false;
    }

    print('You must first install dart.');
    print('See the install instructions at: https://dart.dev/get-dart');

    return false;
  }
}
