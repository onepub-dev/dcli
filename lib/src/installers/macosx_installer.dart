import '../../dshell.dart';

///
/// Installs dart on an apt base system.abstract
///

class MacOsxDshellInstaller {
  /// returns true if it needed to install dart.
  bool install() {
    // first check that dart isn't already installed
    if (which('dart').firstLine != null) {
      // nothing to do dart is already installed.
      Settings().verbose(
          "Found dart at: ${which('dart').firstLine} and as such will not install dart.");
      return false;
    }

    print('You must first install dart.');
    print('See the install instructions at: https://dart.dev/get-dart');

    // The normal dart detection process won't work here
    // as dart is not on the path so for the moment so we hard code it.
    // CONSIDER a way of identifying where dart has been installed to.
    '/usr/lib/dart/bin/pub global activate dshell'.run;

    // also need to install it for the root user
    // as root must have its own copy of .pub-cache otherwise
    // if it updates .pub-cache of a user the user won't be able
    // to use pub-get any more.
    '/usr/lib/dart/bin/pub global activate dshell'.run;

    // yes we installed dart.
    return true;
  }
}
