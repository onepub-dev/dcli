import 'dart:io';

import '../../../dshell.dart';
import '../../functions/env.dart';
import '../../functions/which.dart';
import '../../pubspec/global_dependencies.dart';
import '../../settings.dart';
import '../../shell/shell.dart';
import '../../util/ansi_color.dart';
import '../../util/dart_install_apt.dart';
import '../../util/dshell_paths.dart';
import '../../util/pub_cache.dart';
import '../command_line_runner.dart';
import '../flags.dart';
import 'commands.dart';

///
class InstallCommand extends Command {
  static const _commandName = 'install';

  final _installFlags = [_NoCleanFlag()];

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  /// ctor.
  InstallCommand() : super(_commandName);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var scriptIndex = 0;

    var shell = ShellDetection().identifyShell();

    // if (!shell.isPrivilegedUser) {
    //   print(red(shell.privilegesRequiredMessage('dshell_install')));
    //   exit(1);
    // }

    // check for any flags
    int i;
    for (i = 0; i < subarguments.length; i++) {
      final subargument = subarguments[i];

      if (Flags.isFlag(subargument)) {
        var flag = flagSet.findFlag(subargument, _installFlags);

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
      throw InvalidArguments(
          "'dshell install' does not take any arguments. Found $subarguments");
    }

    print('Hang on a tick whilst we install dshell.');
    print('');

    var dartWasInstalled = _dartInstall();
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
        'Creating ${join(Settings().dshellPath, GlobalDependencies.filename)} with default packages.');
    print(blue2);
    GlobalDependencies.createDefault();

    print('Default packages are:');
    for (var dep in GlobalDependencies.defaultDependencies) {
      print('  ${dep.rehydrate()}');
    }
    print('');
    print(
        'Edit ${GlobalDependencies.filename} to add/remove/update your default dependencies.');

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
    }

    // create the bin directory
    var binPath = Settings().dshellBinPath;
    if (!exists(binPath)) {
      print('');
      print(blue('Creating bin directory in: $binPath.'));
      createDir(binPath);

      if (!shell.addToPath(binPath)) {
        printerr(
            'If you want to use dshell compile -i to install scripts, add $binPath to your PATH.');
      }
    }

    print('');

    if (shell.isCompletionSupported) {
      if (!shell.isCompletionInstalled) {
        shell.installTabCompletion();
      }
    }

    // If we just installed dart then we don't need
    // to check the dshell paths.
    if (!dartWasInstalled) {
 
      var dshellLocation =
          which(DShellPaths().dshellName, first: true).firstLine;
      // check if dshell is on the path
      if (dshellLocation == null) {
        print('');
        print('ERROR: dshell was not found on your path!');
        print("Try running 'pub global activate dshell' again.");
        print('  otherwise');
        print('Try to resolve the problem and then run dshell install again.');
        print('dshell is normally located in ${PubCache().binPath}');

        if (!PATH.contains(PubCache().binPath)) {
          print('Your path does not contain ${PubCache().binPath}');
        }
        exit(1);
      } else {
        var dshellPath = dshellLocation;
        print(blue('dshell found in : $dshellPath.'));

        // link so all users can run dshell
        // We use the location of dart exe and add dshell symlink
        // to the same location.
        // CONSIDER: this is going to require sudo to install???
        //var linkPath = join(dirname(DartSdk().exePath), 'dshell');
        //symlink(dshellPath, linkPath);
      }
    }
    print('');

    _fixPermissions(shell);

    // print('Copying dshell (${Platform.executable}) to /usr/bin/dshell');
    // copy(Platform.executable, '/usr/bin/dshell');

    touch(Settings().installCompletedIndicator, create: true);

    if (dartWasInstalled)
    {          print('');
      print(red('You need to restart your shell so the new paths can update'));
      print('');
    }


    print(red('*' * 80));
    print('');
    print('dshell installation complete.');
    print('');
    print(red('*' * 80));

    print('');
    print('Create your first dshell script using:');
    print(blue('  dshell create <scriptname>.dart'));
    print('');
    print(blue('  Run your script by typing:'));
    print(blue('  ./<scriptname>.dart'));

    return 0;
  }

  @override
  String description() =>
      """Running 'dshell install' completes the installation of dshell.""";

  @override
  String usage() => 'install';

  @override
  List<String> completion(String word) {
    return <String>[];
  }

  @override
  List<Flag> flags() {
    return _installFlags;
  }

  bool _dartInstall() {
    return DartInstaller().installDart();
  }

  void _fixPermissions(Shell shell) {
    // if (shell.isPrivilegedUser) {
    //   if (!Platform.isWindows) {
    //     var user = shell.loggedInUser;
    //     if (user != 'root') {
    //       'chmod -R $user:$user ${Settings().dshellPath}'.run;
    //       'chmod -R $user:$user ${PubCache().path}'.run;
    //     }
    //   }
    // }
  }
}

class _NoCleanFlag extends Flag {
  static const _flagName = 'noclean';

  _NoCleanFlag() : super(_flagName);

  @override
  String get abbreviation => 'nc';

  @override
  String description() {
    return '''Stops the install from running 'dshell cleanall' as part of the install.
      This option is for testing purposes. 
      When doing a dshell upgrade you should always allow install to do a clean all.''';
  }
}

/// Thrown if an error is encountered during an install
class InstallException extends DShellException {
  /// Thrown if an error is encountered during an install
  InstallException(String message) : super(message);
}
