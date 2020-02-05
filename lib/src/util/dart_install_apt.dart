import 'package:dshell/dshell.dart';
import 'package:path/path.dart';

///
/// Installs dart on an apt base system.abstract
///

class AptDartInstaller implements DartInstaller {
  /// returns true if it needed to install dart.
  @override
  bool installDart() {
    // first check that dart isn't already installed
    if (which('dart').firstLine != null) {
      // nothing to do dart is already installed.
      Settings().verbose(
          "Found dart at: ${which('dart').firstLine} and as such will not install dart.");
      return false;
    }

    print('Installing Dart');

    // add dart to bash path

    if (!(isOnPath('/usr/bin/dart') || isOnPath('/usr/lib/bin/dart'))) {
      // we need to add it.
      var bashrc = join(HOME, '.bashrc');
      // bashrc.append('''export PATH="\$PATH:/usr/lib/dart/bin"''');

      bashrc.append('''export PATH="\$PATH":"$HOME/.pub-cache/bin"''');

      // add to root path.
      var rootBashrc = join('/root', '.bashrc');
      rootBashrc.append('''export PATH="\$PATH:/usr/lib/dart/bin"''');
      rootBashrc.append('''export PATH="\$PATH:/root/.pub-cache/bin"''');

      print('You will need to restart your shell for dart to be available');
    }

    'sudo apt-get update'.run;
    'sudo apt-get install apt-transport-https'.run;

    "sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'"
        .run;

    "sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'"
        .run;
    'sudo apt-get update'.run;
    'sudo apt install dart'.run;

    // The normal dart detection process wont' work here
    // as dart is not on the path so for the momemnt we hard code it.
    // CONSIDER a way of identifynig where dart has been installed to.
    '/usr/lib/dart/bin/pub global activate dshell'.run;

    // also need to install it for the root user.
    'sudo /usr/lib/dart/bin/pub global activate dshell'.run;

    // yes we installed dart.
    return true;
  }
}

class DartInstaller {
  bool installDart() {
    if (which('apt').firstLine != null) {
      return AptDartInstaller().installDart();
    }
    return false;
  }
}
