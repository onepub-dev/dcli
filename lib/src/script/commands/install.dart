import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/functions/env.dart';
import 'package:dshell/src/script/commands/clean_all.dart';
import 'package:dshell/src/util/dart_install_apt.dart';
import 'package:dshell/src/util/pub_cache.dart';
import 'package:dshell/src/util/shell.dart';

import '../../functions/which.dart';
import '../../pubspec/global_dependencies.dart';
import '../command_line_runner.dart';
import '../../settings.dart';
import '../../util/ansi_color.dart';

import '../flags.dart';
import 'commands.dart';

class InstallCommand extends Command {
  static const String NAME = 'install';

  List<Flag> installFlags = [NoCleanFlag()];

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  InstallCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var exitCode = 0;
    var scriptIndex = 0;

    // check the user
    if (Settings().isLinux || Settings().isMacOS) {
      var user = 'whoami'.firstLine;
      if (user != null) {
        if (user[0] == 'root') {
          printerr('dshell install MUST not be run as root.');
        }
      }
    }

    // check for any flags
    int i;
    for (i = 0; i < subarguments.length; i++) {
      final subargument = subarguments[i];

      if (Flags.isFlag(subargument)) {
        var flag = flagSet.findFlag(subargument, installFlags);

        if (flag != null) {
          if (flagSet.isSet(flag)) {
            throw DuplicateOptionsException(subargument);
          }
          flagSet.set(flag);
          Settings().verbose('Setting flag: ${flag.name}');
          continue;
        } else {
          throw UnknownFlag(subargument);
        }
      }

      break;
    }
    scriptIndex = i;

    if (subarguments.length != scriptIndex) {
      throw CommandLineException(
          "'dshell install' does not take any arguments. Found $subarguments");
    }

    print('Hang on a tick whilst we install dshell.');
    print('');

    var dartWasInstalled = dartInstall();
    // Create the ~/.dshell root.
    if (!exists(Settings().dshellPath)) {
      print(blue('Creating ${Settings().dshellPath}'));
      createDir(Settings().dshellPath);
    } else {
      print('Found existing install at: ${Settings().dshellPath}.');
    }
    print('');

    // Create dependencies.yaml
    var blue2 = blue(
        'Creating ${Settings().dshellPath}/dependencies.yaml with default packages.');
    print(blue2);
    GlobalDependencies.createDefault();

    print('Default packages are:');
    for (var dep in GlobalDependencies.defaultDependencies) {
      print('  ${dep.name}:${dep.version}');
    }
    print('');
    print(
        'Edit dependencies.yaml to add/remove/update your default dependencies.');

    /// create the template directory.
    if (!exists(Settings().templatePath)) {
      print('');
      print(
          blue('Creating Template directory in: ${Settings().templatePath}.'));
      createDir(Settings().templatePath);
    }

    /// create the cache directory.
    if (!exists(Settings().dshellCachePath)) {
      print('');
      print(
          blue('Creating Cache directory in: ${Settings().dshellCachePath}.'));
      createDir(Settings().dshellCachePath);
    } else {
      print('');
      if (!flagSet.isSet(NoCleanFlag())) {
        // make certain the project is upto date.
        print(blue("Running 'clean all' to upgrade your existing scripts"));
        CleanAllCommand().run([], []);
      } else {
        print(blue('Skipping clean as -nc flag passed.'));
      }
    }

    var shell = ShellDetection().identifyShell();

    // create the bin directory
    var binPath = Settings().dshellBinPath;
    if (!exists(binPath)) {
      print('');
      print(blue('Creating bin directory in: $binPath.'));
      createDir(binPath);

      if (!shell.addToPath(binPath)) {
        printerr(
            'If you want to use dshell compile -i to install scripts, then you need to manually add $binPath to your PATH.');
      }
    }

    print('');

    if (shell.isCompletionSupported) {
      if (!shell.isCompletionInstalled) {
        shell.installTabCompletion();
      }
    }

    // print OS version.
    // print('Platform.version ${Platform.version}');

    // If we just installed dart there is no pont
    if (dartWasInstalled) {
      print('');
      print(red('You need to restart your shell so the new paths can update'));
      print('');
    } else {
      var dshellLocation = which('dshell', first: true).firstLine;
      // check if dshell is on the path
      if (dshellLocation == null) {
        print('');
        print('ERROR: dshell was not found on your path!');
        print("Try running 'pub global activate dshell' again.");
        print('  otherwise');
        print('Try to resolve the problem and then run dshell install again.');
        print('dshell is normally located in ${PubCache().path}');

        if (!PATH.contains(PubCache().path)) {
          print('Your path does not contain ${PubCache().path}');
        }
        exit(1);
      } else {
        var dshellPath = dshellLocation;
        print(blue('dshell found in : ${dshellPath}.'));

        // link so all users can run dshell
        // We use the location of dart exe and add dshell symlink
        // to the same location.
        // CONSIDER: this is going to require sudo to install???
        //var linkPath = join(dirname(DartSdk().exePath), 'dshell');
        //symlink(dshellPath, linkPath);
      }
    }
    print('');

    // print('Copying dshell (${Platform.executable}) to /usr/bin/dshell');
    // copy(Platform.executable, '/usr/bin/dshell');

    print('dshell installation complete.');
    print('');
    print('Create your first dshell script using:');
    print(blue('  dshell create <scriptname>.dart'));
    print('');
    print(blue('  Run your script by typing:'));
    print(blue('  ./<scriptname>.dart'));

    return exitCode;
  }

  @override
  String description() =>
      """Running 'dshell install' completes the installation of dshell.""";

  @override
  String usage() => 'Install';

  @override
  List<String> completion(String word) {
    return <String>[];
  }

  @override
  List<Flag> flags() {
    return installFlags;
  }

  bool dartInstall() {
    return DartInstaller().installDart();
  }
}

class NoCleanFlag extends Flag {
  static const NAME = 'noclean';

  NoCleanFlag() : super(NAME);

  @override
  String get abbreviation => 'nc';

  @override
  String description() {
    return '''Stops the install from running 'dshell cleanall' as part of the install.
      This option is for testing purposes. 
      When doing a dshell upgrade you should always all install to do a clean all.''';
  }
}
