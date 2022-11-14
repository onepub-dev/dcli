import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:dcli/posix.dart';
import 'package:path/path.dart';

import '../args/global_args.dart';
import '../exceptions/app_exception.dart';
import '../settings/app_settings.dart';

class InstallCommand extends Command<void> {
  InstallCommand() {
    argParser
      ..addOption(pathOption,
          abbr: 'p', help: 'The path to install mail hog into')
      ..addFlag(overwriteOption,
          abbr: 'o',
          help: 'If [path] exists then the install will fail unless you pass '
              'the $overwriteOption.');
  }

  // command options
  static const pathOption = 'path';
  static const overwriteOption = 'overwrite';

  /// name of the command. The user uses this name to run the command.
  @override
  String get name => 'install';

  @override
  String get description => '''
Installs mailhog into $HOME/apps/mailhog.
Use the $pathOption to select an alternate install path.
''';

  /// run the installation.
  @override
  Future<void> run() async {
    final args = InstallArgs.parse(argResults, globalResults);

    _createDir(args);
    _download(args);
  }

  void _download(InstallArgs args) {
    print(orange('Downloading mailhog'));
    delete(args.pathToMailHogApp);
    fetch(
        url:
            'https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64',
        saveToPath: args.pathToMailHogApp);
    // make the app executable.
    chmod(permission: '755', args.pathToMailHogApp);
    print('Installation complete.');
    print('To start mailhog:  ${basename(Platform.script.path)} run');
  }

  /// create the mailhog install directory.
  void _createDir(InstallArgs args) {
    final pathToMailHogDir = dirname(args.pathToMailHogApp);

    if (exists(pathToMailHogDir)) {
      if (!args.overwrite) {
        /// the directory exists but we don't have permission to overwrite it.
        throw ExitException(
            1,
            '''
The install directory ${truepath(pathToMailHogDir)} exists.

Pass --$overwriteOption to install over the existing directory
or --path to specify an alternate directory.''',
            showUsage: false);
      }
    } else {
      createDir(pathToMailHogDir, recursive: true);
    }
  }

  static String get mailHogDirectoryPath => join(HOME, 'apps', 'mailhog');

  static String get defaultMailHogAppPath =>
      join(mailHogDirectoryPath, mailHogAppname);

  static String get mailHogAppname => 'mailhog';
}

/// Parse the command line args specific to the install command
/// including any global arguments.
class InstallArgs extends GlobalArgs {
  InstallArgs.parse(ArgResults? results, ArgResults? globalResults)
      : super(globalResults) {
    /// get the --path option if provided.
    if (results!.wasParsed(InstallCommand.pathOption)) {
      pathToMailHogApp = join(results[InstallCommand.pathOption] as String,
          InstallCommand.mailHogAppname);
    } else {
      pathToMailHogApp = AppSettings().pathToMailHogApp;
    }
    AppSettings().pathToMailHogApp =
        join(pathToMailHogApp, InstallCommand.mailHogAppname);

    /// get the overwrite option.
    overwrite = results[InstallCommand.overwriteOption] as bool;
  }

  /// path the (to be) installed mailhog app including its filename.
  late final String pathToMailHogApp;

  /// allow the install to overwrite the existing install
  late final bool overwrite;
}
