import 'package:path/path.dart';
import '../../dshell.dart';
import '../shell/shell_detection.dart';
import '../util/pub_cache.dart';

///
/// Installs dart on an apt base system.abstract
///

class LinuxDShellInstaller {
  /// returns true if it needed to install dart.
  bool install() {
    var installedDart = false;

    // first check that dart isn't already installed
    if (which('dart').firstLine == null) {
      print('Installing Dart');

      // add dart to bash path

      if (!(isOnPath('/usr/bin/dart') || isOnPath('/usr/lib/bin/dart'))) {
        // we need to add it.
        var bashrc = join(HOME, '.bashrc');
        bashrc.append('''export PATH="\$PATH":"/usr/lib/dart/bin"''');
        bashrc.append('''export PATH="\$PATH":"${PubCache().binPath}"''');
        bashrc.append('''export PATH="\$PATH":"${Settings().dshellBinPath}"''');

        var shell = ShellDetection().identifyShell();
        Settings().verbose('Found shell: shell');
        if (shell.loggedInUser != 'root') {
          // add dart to root path.
          // The tricks we have to play to get dart on the root users path.
          'echo export PATH="\$PATH:/usr/lib/dart/bin" | sudo tee -a /root/.bashrc'
              .run;
          // give root its own pub-cache
          'echo export PATH="\$PATH":"/root/.pub-cache/bin" | sudo tee -a /root/.bashrc'
              .run;
        }

        print('You will need to restart your shell for dart to be available');
      }

      /// check that apt is available.
      if (which('apt').firstLine != null) {
        Settings().verbose('Usimg the apt installer');
        _installDartWithApt();
      } else {
        Settings().verbose('Apt not found. Installing from archive');
        DartSdk().installFromArchive('/usr/lib/dart', askUser: false);
      }

      installedDart = true;
    } else {
      // dart is already installed.
      Settings().verbose(
          "Found dart at: ${which('dart').firstLine} and as such will not install dart.");
    }

    // now activate dshell.
    // The normal dart detection process won't work here
    // as dart is not on the path so for the moment so we hard code it.
    // CONSIDER a way of identifying where dart has been installed to.
    '/usr/lib/dart/bin/pub global activate dshell'.run;

    // // also need to install it for the root user
    // // as root must have its own copy of .pub-cache otherwise
    // // if it updates .pub-cache of a user the user won't be able
    // // to use pub-get any more.
    // '/usr/lib/dart/bin/pub global activate dshell'.run;

    return installedDart;
  }

  void _installDartWithApt() {
    'apt update'.run;
    'apt install apt-transport-https'.run;

    "sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'"
        .run;

    "sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'"
        .run;
    'apt update'.run;
    'apt install dart'.run;
  }
}
