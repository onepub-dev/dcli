import '../../../dcli.dart';

import '../command_line_runner.dart';
import '../flags.dart';
import '../project_cache.dart';
import 'commands.dart';

/// upgrades dcli by running:
/// pub global active dcli
/// and then cleaning all projects.
class UpgradeCommand extends Command {
  static const String _commandName = 'upgrade';

  ///
  UpgradeCommand() : super(_commandName);

  /// The upgrade command takes no arguments.
  /// current directory are upgradeed.
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.isNotEmpty) {
      throw InvalidArguments('dcli upgrade does not take any arguments.');
    }

    var currentVersion = Settings().version;

    print(red('Upgrading dcli...'));
    print('Current version $currentVersion');
    startFromArgs(DartSdk().pubPath, ['global', 'activate', 'dcli'],
        progress: Progress.print());

    Settings().verbose('pub global activate dcli finished');

    upgradeVersion(currentVersion);

    print('');
    print(green('Running clean all to upgrade scripts.'));
    ProjectCache().cleanAll();

    print('');
    print(red('*' * 80));
    print('');
    print('DCli upgrade completed.');
    print('');
    'dcli version'.run;
    print('');
    print(red('*' * 80));

    return 0;
  }

  /// place holder which will be used to make any modifications
  /// required to the dcli directory structure or files
  /// as part of an upgrade.
  void upgradeVersion(String currentVersion) {}

  @override
  String usage() => 'upgrade';

  @override
  String description() =>
      '''Upgrades dcli to the latest version and cleans all of your projects.''';

  @override
  List<String> completion(String word) {
    return [];
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
