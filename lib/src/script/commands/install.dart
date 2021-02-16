import 'dart:io';

import 'package:dcli/src/templates/expander.dart';
import 'package:dcli/src/version/version.g.dart';
import 'package:meta/meta.dart';

import '../../../dcli.dart';
import '../../functions/env.dart';
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

  final _installFlags = const [
    _NoDartFlag(),
    _QuietFlag(),
    _NoPrivilegesFlag()
  ];

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  /// set by the [_QuietFlag].
  /// if [_quiet] is true only errors are displayed during the install.
  bool _quiet = false;

  /// set by the [_NoDartFlag].
  /// If [_installDart] is true then we won't attempt to install dart.
  bool _installDart = false;

  bool _requirePrivileges = false;

  /// ctor.
  InstallCommand() : super(_commandName);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var scriptIndex = 0;

    final shell = Shell.current;

    // check for any flags
    int i;
    for (i = 0; i < subarguments.length; i++) {
      final subargument = subarguments[i];

      if (Flags.isFlag(subargument)) {
        final flag = flagSet.findFlag(subargument, _installFlags);

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

    _requirePrivileges = !flagSet.isSet(const _NoPrivilegesFlag());

    // /// We need to be priviledged to create the dcli symlink
    // if (requirePrivileges && !shell.isPrivilegedUser) {
    //   qprint(red(shell.privilegesRequiredMessage('dcli_install')));
    //   exit(1);
    // }

    _quiet = flagSet.isSet(const _QuietFlag());
    _installDart = !flagSet.isSet(const _NoDartFlag());

    if (_quiet) {
      print('Installing DCli v$packageVersion ...');
    }
    qprint('Hang on a tick whilst we install DCli ${Settings().version}');

    qprint('');

    final conditions = shell.checkInstallPreconditions();
    if (conditions != null) {
      printerr(red('*' * 80));
      printerr(red(conditions));
      printerr(red('*' * 80));
      exit(1);
    }
    // install dart and dcli
    final dartWasInstalled = shell.install(installDart: _installDart);

    // Create the ~/.dcli root.
    if (!exists(Settings().pathToDCli)) {
      qprint(blue('Creating ${Settings().pathToDCli}'));
      createDir(Settings().pathToDCli);
    } else {
      qprint('Found existing install at: ${Settings().pathToDCli}.');
    }
    qprint('');

    /// create the template directory.
    if (!exists(Settings().pathToTemplate)) {
      qprint('');
      qprint(blue(
          'Creating Template directory in: ${Settings().pathToTemplate}.'));
      initTemplates();
    }

    /// create the cache directory.
    if (!exists(Settings().pathToDCliCache)) {
      qprint('');
      qprint(
          blue('Creating Cache directory in: ${Settings().pathToDCliCache}.'));
      createDir(Settings().pathToDCliCache);
    }

    // create the bin directory
    final binPath = Settings().pathToDCliBin;
    if (!exists(binPath)) {
      qprint('');
      qprint(blue('Creating bin directory in: $binPath.'));
      createDir(binPath);

      // check if shell can add a path.
      if (!shell.hasStartScript || !shell.addToPATH(binPath)) {
        qprint(orange(
            'If you want to use dcli compile -i to install scripts, add $binPath to your PATH.'));
      }
    }

    qprint('');

    if (shell.isCompletionSupported) {
      if (!shell.isCompletionInstalled) {
        shell.installTabCompletion();
      }
    }

    // the dcli executable has just been installed by dart pub global activate
    final dcliLocation = join(PubCache().pathToBin, DCliPaths().dcliName);
    // check if dcli is on the path
    if (!exists(dcliLocation)) {
      print('');
      print('ERROR: dcli was not found on your path!');
      print("Try running 'dart pub global activate dcli' again.");
      print('  otherwise');
      print('Try to resolve the problem and then run dcli install again.');
      print('dcli is normally located in ${PubCache().pathToBin}');

      if (!PATH.contains(PubCache().pathToBin)) {
        print('Your path does not contain ${PubCache().pathToBin}');
      }
      exit(1);
    } else {
      final dcliPath = dcliLocation;
      qprint(blue('dcli found in : $dcliPath.'));

      if (_requirePrivileges) {
        symlinkDCli(shell, dcliPath);
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

  /// Symlink so dcli works under sudo.
  /// We use the location of dart exe and add dcli symlink
  /// to the same location.
  void symlinkDCli(Shell shell, String dcliPath) {
    if (!Platform.isWindows) {
      final linkPath = join(dirname(DartSdk().pathToDartExe!), 'dcli');
      'ln -sf $dcliPath $linkPath'.start(privileged: true);
      // symlink(dcliPath, linkPath);
    }
  }

  void qprint(String? message) {
    if (!_quiet) print(message);
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
    if (shell.isPrivilegedUser) {
      if (!Platform.isWindows) {
        final user = shell.loggedInUser;
        if (user != 'root') {
          'chown -R $user:$user ${Settings().pathToDCli}'.run;
          'chown -R $user:$user ${PubCache().pathTo}'.run;
        }
      }
    }
  }

  /// Checks if the templates directory exists and .dcli and if not creates
  /// the directory and copies the default scripts in.
  @visibleForTesting
  void initTemplates() {
    if (!exists(Settings().pathToTemplate)) {
      createDir(Settings().pathToTemplate, recursive: true);
    }

    TemplateExpander(Settings().pathToTemplate).expand();
  }
}

class _NoDartFlag extends Flag {
  static const _flagName = 'nodart';

  const _NoDartFlag() : super(_flagName);

  @override
  String get abbreviation => 'nd';

  @override
  String description() {
    return '''
Stops the install from installing dart as part of the install.
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

class _NoPrivilegesFlag extends Flag {
  static const _flagName = 'noprivileges';

  const _NoPrivilegesFlag() : super(_flagName);

  @override
  String get abbreviation => 'np';

  @override
  String description() {
    return '''
Allows the install to be run without privileges. This flag is primarily used for unit testing.
      Some features will not be available if you run in this mode.''';
  }
}

/// Thrown if an error is encountered during an install
class InstallException extends DCliException {
  /// Thrown if an error is encountered during an install
  InstallException(String message) : super(message);
}
