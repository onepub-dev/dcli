import 'package:dshell/dshell.dart';

import '../command_line_runner.dart';
import '../flags.dart';
import '../project_cache.dart';
import 'commands.dart';

/// upgrades dshell by running:
/// pub global active dshell
/// and then cleaning all projects.
class UpgradeCommand extends Command {
  static const String NAME = 'upgrade';

  UpgradeCommand() : super(NAME);

  /// The upgrade command takes no arguments.
  /// current directory are upgradeed.
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.isNotEmpty) {
      throw InvalidArguments('dshell upgrade does not take any arguments.');
    }

    var currentVersion = Settings().version;

    print(red('Upgrading dshell...'));
    print('Current version $currentVersion');
    startFromArgs(DartSdk().pubPath, ['global', 'activate', 'dshell'],
        progress: Progress.print());

    Settings().verbose('pub global activate dshell finished');

    upgradeVersion(currentVersion);

    print('');
    print(green('Running clean all to upgrade scripts.'));
    ProjectCache().cleanAll();

    print('');
    print(red('*' * 80));
    print('');
    print('Dshell upgrade completed.');
    print('');
    'dshell version'.run;
    print('');
    print(red('*' * 80));

    return 0;
  }

  /// place holder which will be used to make any modifications
  /// required to the dshell directory structure or files
  /// as part of an upgrade.
  void upgradeVersion(String currentVersion) {}

  @override
  String usage() => 'upgrade';

  @override
  String description() =>
      '''Upgrades dshell to the latest version and cleans all of your projects.''';

  @override
  List<String> completion(String word) {
    return [];
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
