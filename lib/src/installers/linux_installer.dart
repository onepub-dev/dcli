import 'package:path/path.dart';
import '../../dcli.dart';
import '../shell/shell_detection.dart';
import '../util/pub_cache.dart';

///
/// Installs dart on an apt base system.abstract
///

class LinuxDCliInstaller {
  /// returns true if it needed to install dart.
  bool install({bool installDart}) {
    const installedDart = false;

    if (installDart) _installDart();

    // now activate dcli.
    final pubPath = determinePubPath();
    '$pubPath global activate dcli'.start(progress: Progress.printStdErr());

    // // also need to install it for the root user
    // // as root must have its own copy of .pub-cache otherwise
    // // if it updates .pub-cache of a user the user won't be able
    // // to use pub-get any more.
    // '/usr/lib/dart/bin/pub global activate dcli'.run;

    return installedDart;
  }

  bool _installDart() {
    var installedDart = false;
    // first check that dart isn't already installed
    if (which('dart').notfound) {
      print('Installing Dart');

      // add dart to bash path
      if (!(isOnPATH('/usr/bin/dart') || isOnPATH('/usr/lib/bin/dart'))) {
        // we need to add it.
        final bashrc = join(HOME, '.bashrc');
        bashrc.append('''export PATH="\$PATH":"/usr/lib/dart/bin"''');
        bashrc.append('''export PATH="\$PATH":"${PubCache().pathToBin}"''');
        bashrc.append('''export PATH="\$PATH":"${Settings().pathToDCliBin}"''');

        final shell = ShellDetection().identifyShell();
        Settings().verbose('Found shell: shell');
        if (shell.loggedInUser != 'root') {
          // add dart to root path.
          // The tricks we have to play to get dart on the root users path.
          'echo export PATH="\$PATH":/usr/lib/dart/bin | sudo tee -a /root/.bashrc'
              .run;
          // give root its own pub-cache
          'echo export PATH="\$PATH":/root/.pub-cache/bin | sudo tee -a /root/.bashrc'
              .run;
        }

        print('You will need to restart your shell for dart to be available');
      }

      /// check that apt is available.
      if (which('apt').found) {
        Settings().verbose('Using the apt installer');
        _installDartWithApt();
      } else {
        Settings().verbose('Apt not found. Installing from archive');
        final dartInstallDir =
            DartSdk().installFromArchive('/usr/lib/dart', askUser: false);
        print('Installed dart to: $dartInstallDir');
      }

      installedDart = true;
    } else {
      // dart is already installed.
      Settings().verbose(
          "Found dart at: ${which('dart').path ?? "<not found>"} and as such will not install dart.");
    }

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

  // The normal dart detection process may not work here
  // as dart may not be on the path
  // So lets go find it
  // CONSIDER a way of identifying where dart has been installed to.

  String determinePubPath() {
    var pubPath = which('pub').path;

    if (pubPath == null) {
      /// lets try some likely locations

      pubPath = '/usr/lib/dart/bin/pub';
      if (exists(pubPath)) return pubPath;

      pubPath = '/usr/bin/pub';
      if (exists(pubPath)) return pubPath;
    }

    /// radical - search everywhere
    /// The performance of find essentially precludes this.
    // print('Searching for pub');
    // // pubPath =
    // find('pub', workingDirectory: '/', progress: Progress.print());

    return pubPath;
  }
}
