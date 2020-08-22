import 'dart:io';

import '../../../dcli.dart';
import '../../functions/env.dart';
import '../../functions/which.dart';
import '../../pubspec/global_dependencies.dart';
import '../../settings.dart';
import '../../shell/shell.dart';
import '../../util/ansi_color.dart';
import '../../util/dcli_paths.dart';
import '../../util/pub_cache.dart';
import '../command_line_runner.dart';
import '../flags.dart';
import 'commands.dart';

///
class InstallCommand extends Command {
  static const _commandName = 'install';

  final _installFlags = const [_NoCleanFlag(), _NoDartFlag(), _QuietFlag()];

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  /// set by the [_QuietFlag].
  /// if [quiet] is true only errors are displayed during the install.
  bool quiet = false;

  /// ctor.
  InstallCommand() : super(_commandName);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var scriptIndex = 0;

    var shell = Shell.current;

    // if (!shell.isPrivilegedUser) {
    //   qprint(red(shell.privilegesRequiredMessage('dcli_install')));
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
          "'dcli install' does not take any arguments. Found $subarguments");
    }

    quiet = flagSet.isSet(_QuietFlag());

    if (quiet) {
      print('Installing DCli...  ');
    }
    qprint('Hang on a tick whilst we install DCli ${Settings().version}');

    qprint('');

    var conditions = shell.checkInstallPreconditions();
    if (conditions != null) {
      printerr(red('*' * 80));
      printerr(red('$conditions'));
      printerr(red('*' * 80));
      exit(1);
    }
    var dartWasInstalled = shell.install();
    // Create the ~/.dcli root.
    if (!exists(Settings().dcliPath)) {
      qprint(blue('Creating ${Settings().dcliPath}'));
      createDir(Settings().dcliPath);
    } else {
      qprint('Found existing install at: ${Settings().dcliPath}.');
    }
    qprint('');

    // Create dependencies.yaml
    var blue2 = blue(
        'Creating ${join(Settings().dcliPath, GlobalDependencies.filename)} with default packages.');
    qprint(blue2);
    GlobalDependencies.createDefault();

    qprint('Default packages are:');
    for (var dep in GlobalDependencies.defaultDependencies) {
      qprint('  ${dep.rehydrate()}');
    }
    qprint('');
    qprint(
        'Edit ${GlobalDependencies.filename} to add/remove/update your default dependencies.');

    /// create the template directory.
    if (!exists(Settings().templatePath)) {
      qprint('');
      qprint(
          blue('Creating Template directory in: ${Settings().templatePath}.'));
      createDir(Settings().templatePath);
    }

    /// create the cache directory.
    if (!exists(Settings().dcliCachePath)) {
      qprint('');
      qprint(blue('Creating Cache directory in: ${Settings().dcliCachePath}.'));
      createDir(Settings().dcliCachePath);
    }

    // create the bin directory
    var binPath = Settings().dcliBinPath;
    if (!exists(binPath)) {
      qprint('');
      qprint(blue('Creating bin directory in: $binPath.'));
      createDir(binPath);

      // check if shell can add a path.
      if (!shell.hasStartScript || !shell.addToPath(binPath)) {
        qprint(orange(
            'If you want to use dcli compile -i to install scripts, add $binPath to your PATH.'));
      }
    }

    qprint('');

    if (shell.isCompletionSupported) {
      if (!shell.isCompletionInstalled) {
        shell.installTabCompletion(quiet: true);
      }
    }

    // If we just installed dart then we don't need
    // to check the dcli paths.
    if (!dartWasInstalled) {
      var dcliLocation = which(DCliPaths().dcliName, first: true).firstLine;
      // check if dcli is on the path
      if (dcliLocation == null) {
        print('');
        print('ERROR: dcli was not found on your path!');
        print("Try running 'pub global activate dcli' again.");
        print('  otherwise');
        print('Try to resolve the problem and then run dcli install again.');
        print('dcli is normally located in ${PubCache().binPath}');

        if (!PATH.contains(PubCache().binPath)) {
          print('Your path does not contain ${PubCache().binPath}');
        }
        exit(1);
      } else {
        var dcliPath = dcliLocation;
        qprint(blue('dcli found in : $dcliPath.'));

        // link so all users can run dcli
        // We use the location of dart exe and add dcli symlink
        // to the same location.
        // CONSIDER: this is going to require sudo to install???
        //var linkPath = join(dirname(DartSdk().exePath), 'dcli');
        //symlink(dcliPath, linkPath);
      }
    }
    qprint('');

    _fixPermissions(shell);

    // qprint('Copying dcli (${Platform.executable}) to /usr/bin/dcli');
    // copy(Platform.executable, '/usr/bin/dcli');

    touch(Settings().installCompletedIndicator, create: true);

    if (dartWasInstalled) {
      qprint('');
      qprint(
          red('You need to restart your shell for the adjusted PATH to work.'));
      qprint('');
    }

    qprint(red('*' * 80));
    qprint('');
    // if (quiet) {
    //   print('done.');
    // }

    qprint('dcli installation complete.');

    qprint('');
    qprint(red('*' * 80));

    qprint('');
    qprint('Create your first dcli script using:');
    qprint(blue('  dcli create <scriptname>.dart'));
    qprint('');
    qprint(blue('  Run your script by typing:'));
    qprint(blue('  ./<scriptname>.dart'));

    return 0;
  }

  void qprint(String message) {
    if (!quiet) print(message);
  }

  @override
  String description() =>
      """Running 'dcli install' completes the installation of dcli.""";

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

  void _fixPermissions(Shell shell) {
    // if (shell.isPrivilegedUser) {
    //   if (!Platform.isWindows) {
    //     var user = shell.loggedInUser;
    //     if (user != 'root') {
    //       'chmod -R $user:$user ${Settings().dcliPath}'.run;
    //       'chmod -R $user:$user ${PubCache().path}'.run;
    //     }
    //   }
    // }
  }
}

class _NoCleanFlag extends Flag {
  static const _flagName = 'noclean';

  const _NoCleanFlag() : super(_flagName);

  @override
  String get abbreviation => 'nc';

  @override
  String description() {
    return '''Stops the install from running 'dcli cleanall' as part of the install.
      This option is for testing purposes. 
      When doing a dcli upgrade you should always allow install to do a clean all.''';
  }
}

class _NoDartFlag extends Flag {
  static const _flagName = 'nodart';

  const _NoDartFlag() : super(_flagName);

  @override
  String get abbreviation => 'nd';

  @override
  String description() {
    return '''Stops the install from installing dart as part of the install.
      This option is for testing purposes.''';
  }
}

class _QuietFlag extends Flag {
  static const _flagName = 'quiet';

  const _QuietFlag() : super(_flagName);

  @override
  String get abbreviation => 'q';

  @override
  String description() {
    return '''Runs the install in quiet mode. Only errors are displayed''';
  }
}

/// Thrown if an error is encountered during an install
class InstallException extends DCliException {
  /// Thrown if an error is encountered during an install
  InstallException(String message) : super(message);
}
