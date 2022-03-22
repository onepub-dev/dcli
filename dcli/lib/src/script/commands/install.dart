import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:meta/meta.dart';
import 'package:scope/scope.dart';

import '../../../dcli.dart';
import '../../dcli/resource/generated/resource_registry.g.dart';
import '../../version/version.g.dart';
import '../command_line_runner.dart';
import '../flags.dart';
import 'commands.dart';

///
class InstallCommand extends Command {
  /// ctor.
  InstallCommand() : super(_commandName);
  static const _commandName = 'install';

  final _installFlags = const [
    _NoDartFlag(),
    _QuietFlag(),
    _NoPrivilegesFlag()
  ];

  /// During testing we want to install dcli from source.
  static final activateFromSourceKey = ScopeKey<bool>();

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  /// set by the [_QuietFlag].
  /// if [_quiet] is true only errors are displayed during the install.
  bool _quiet = false;

  /// set by the [_NoDartFlag].
  /// If [_installDart] is false then we won't attempt to install dart.
  bool _installDart = true;

  bool _requirePrivileges = false;

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
          verbose(() => 'Setting flag: ${flag.name}');
          continue;
        } else {
          throw UnknownFlag(subargument);
        }
      }

      break;
    }
    scriptIndex = i;

    if (subarguments.length != scriptIndex) {
      throw InvalidArgumentsException(
        "'dcli install' does not take any arguments. Found $subarguments",
      );
    }

    _requirePrivileges = !flagSet.isSet(const _NoPrivilegesFlag());

    /// We need to be priviledged to create the dcli symlink
    if (_requirePrivileges &&
        core.Settings().isWindows &&
        !shell.isPrivilegedUser) {
      _qprint(red(shell.privilegesRequiredMessage('dcli_install')));
      exit(1);
    }

    shell.releasePrivileges();

    _quiet = flagSet.isSet(const _QuietFlag());
    _installDart = !flagSet.isSet(const _NoDartFlag());

    if (_quiet) {
      print('Installing DCli v$packageVersion ...');
    }
    _qprint(
      green('Hang on a tick whilst we install DCli ${Settings().version}'),
    );

    _qprint('');

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
      _qprint(
        '${blue('Creating')} ${green('.dcli')} '
        '${blue('directory: ${Settings().pathToDCli}')}',
      );
      createDir(Settings().pathToDCli);
    } else {
      _qprint(blue('Found existing install at: ${Settings().pathToDCli}.'));
    }
    _qprint('');

    initTemplates();

    // create the bin directory
    final binPath = Settings().pathToDCliBin;
    if (!exists(binPath)) {
      _qprint('');
      _qprint(
        '${blue('Creating ${green('bin')} ')}'
        '${blue('directory: $binPath.')}',
      );
      createDir(binPath);
    }

    final wasOnPath = Env().isOnPATH(binPath);
    // check if shell can add a path.
    if (shell.canModifyPath && shell.appendToPATH(binPath)) {
      if (!wasOnPath) {
        _qprint(
          orange(
            'You will need to restart your terminal '
            'for DCli to be on your PATH.',
          ),
        );
      }
    } else {
      _qprint(
        orange(
          'If you want to use dcli compile -i to install scripts, '
          'add $binPath to your PATH.',
        ),
      );
    }

    shell.addFileAssocation(binPath);
    _qprint('');

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
      _qprint(blue('dcli found in : $dcliPath.'));

      // if (_requirePrivileges) {
      //   symlinkDCli(shell, dcliPath);
      // }
    }
    _qprint('');

    _fixPermissions(shell);

    // qprint('Copying dcli (${Platform.executable}) to /usr/bin/dcli');
    // copy(Platform.executable, '/usr/bin/dcli');

    touch(Settings().installCompletedIndicator, create: true);

    if (dartWasInstalled) {
      _qprint('');
      _qprint(
        red('You need to restart your shell for the adjusted PATH to work.'),
      );
      _qprint('');
    }

    _qprint(red('*' * 80));
    _qprint('');
    // if (quiet) {
    //   print('done.');
    // }

    _qprint('dcli installation complete.');

    _qprint('');
    _qprint(red('*' * 80));

    _qprint('');
    _qprint('Create your first dcli script using:');
    _qprint(blue('  dcli create <scriptname>.dart'));
    _qprint('');
    _qprint(blue('  Run your script by typing:'));
    _qprint(blue('  ./<scriptname>.dart'));

    return 0;
  }

  /// Symlink so dcli works under sudo.
  /// We use the location of dart exe and add dcli symlink
  /// to the same location.
  void symlinkDCli(Shell shell, String dcliPath) {
    if (!core.Settings().isWindows) {
      final linkPath = join(dirname(DartSdk().pathToDartExe!), 'dcli');
      if (Shell.current.isPrivilegedPasswordRequired && !isWritable(linkPath)) {
        print('Please enter the sudo password when prompted.');
      }

      'ln -sf $dcliPath $linkPath'.start(privileged: !isWritable(linkPath));
      // symlink(dcliPath, linkPath);
    }
  }

  void _qprint(String? message) {
    if (!_quiet) {
      print(message);
    }
  }

  @override
  String description({bool extended = false}) =>
      """Running 'dcli install' completes the installation of dcli.""";

  @override
  String usage() => 'install';

  @override
  List<String> completion(String word) => <String>[];

  @override
  List<Flag> flags() => _installFlags;

  void _fixPermissions(Shell shell) {
    if (shell.isPrivilegedUser) {
      if (!core.Settings().isWindows) {
        final user = shell.loggedInUser;
        if (user != 'root') {
          'chown -R $user:$user ${Settings().pathToDCli}'.run;
          'chown -R $user:$user ${PubCache().pathTo}'.run;
        }
      }
    }
  }

  /// Checks if the template directory exists in ~/.dcli and if not creates
  /// the directory and copies the default scripts in.
  @visibleForTesting
  void initTemplates() {
    initProjectTemplates();
    initScriptTemplates();

    for (final resource in ResourceRegistry.resources.values) {
      if (resource.originalPath.startsWith('template')) {
        resource.unpack(join(Settings().pathToDCli, resource.originalPath));
      }
    }
  }

  void initProjectTemplates() {
    if (!exists(Settings().pathToTemplateProjectCustom)) {
      createDir(Settings().pathToTemplateProjectCustom, recursive: true);
    }

    /// delete all non-custom project templates
    find('*',
            types: [Find.directory],
            workingDirectory: Settings().pathToTemplateProject)
        .forEach((dir) {
      // dont' delete anything under custom.
      if (!dir.startsWith(Settings().pathToTemplateProjectCustom)) {
        /// as we are doing recursive delete we may have already
        /// deleted this directory.
        if (exists(dir)) {
          deleteDir(dir);
        }
      }
    });

    /// create the template directory.
    if (!exists(Settings().pathToTemplateProject)) {
      _qprint(
        '${blue('Creating')} ${green('project templates')} '
        '${blue('directory: ${Settings().pathToTemplateProject}.')}',
      );
    } else {
      _qprint(
        '${blue('Updating ${green('project templates')} ')}'
        '${blue('directory: ${Settings().pathToTemplateProject}.')}',
      );
    }

    if (!exists(Settings().pathToTemplateProject)) {
      createDir(Settings().pathToTemplateProject, recursive: true);
    }

    if (!exists(Settings().pathToTemplateProjectCustom)) {
      createDir(Settings().pathToTemplateProjectCustom, recursive: true);
    }
  }

  void initScriptTemplates() {
    if (!exists(Settings().pathToTemplateScriptCustom)) {
      createDir(Settings().pathToTemplateScriptCustom, recursive: true);
    }

    /// delete all non-custom script templates
    find('*',
            types: [Find.directory],
            workingDirectory: Settings().pathToTemplateScript)
        .forEach((dir) {
      // dont' delete anything under custom.
      if (!dir.startsWith(Settings().pathToTemplateScriptCustom)) {
        deleteDir(dir);
      }
    });

    /// create the template directory.
    if (!exists(Settings().pathToTemplateProject)) {
      _qprint(
        '${blue('Creating')} ${green('script templates')} '
        '${blue('directory: ${Settings().pathToTemplateScript}.')}',
      );
    } else {
      _qprint(
        '${blue('Updating ${green('script template')} ')}'
        '${blue('directory: ${Settings().pathToTemplateScript}.')}',
      );
    }

    if (!exists(Settings().pathToTemplateScript)) {
      createDir(Settings().pathToTemplateScript, recursive: true);
    }

    if (!exists(Settings().pathToTemplateScriptCustom)) {
      createDir(Settings().pathToTemplateScriptCustom, recursive: true);
    }
  }
}

class _NoDartFlag extends Flag {
  const _NoDartFlag() : super(_flagName);

  static const _flagName = 'nodart';

  @override
  String get abbreviation => 'nd';

  @override
  String description() => '''
      Stops the install from installing dart as part of the install.
      This option is for testing purposes.''';
}

class _QuietFlag extends Flag {
  const _QuietFlag() : super(_flagName);
  static const _flagName = 'quiet';

  @override
  String get abbreviation => 'q';

  @override
  String description() => '''
      Runs the install in quiet mode. Only errors are displayed''';
}

class _NoPrivilegesFlag extends Flag {
  const _NoPrivilegesFlag() : super(_flagName);
  static const _flagName = 'noprivileges';

  @override
  String get abbreviation => 'np';

  @override
  String description() => '''
      Allows the install to be run without privileges. This flag is primarily used for unit testing.
      Some features will not be available if you run in this mode.''';
}

/// Thrown if an error is encountered during an install
class InstallException extends DCliException {
  /// Thrown if an error is encountered during an install
  InstallException(String message) : super(message);
}
