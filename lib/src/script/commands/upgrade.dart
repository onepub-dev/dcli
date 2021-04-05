import '../../../dcli.dart';

import '../command_line_runner.dart';
import '../flags.dart';
import 'commands.dart';

/// upgrades dcli by running:
/// pub global active dcli
/// and then preparing all projects.
class UpgradeCommand extends Command {
  ///
  UpgradeCommand() : super(_commandName);
  static const String _commandName = 'upgrade';

  /// The upgrade command takes no arguments.
  /// current directory are upgradeed.
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.isNotEmpty) {
      throw InvalidArguments('dcli upgrade does not take any arguments.');
    }

    final currentVersion = Settings().version;

    print(red('Upgrading dcli...'));
    print('Current version $currentVersion');
    DartSdk().globalActivate('dcli');

    Settings().verbose('dart pub global activate dcli finished');

    upgradeVersion(currentVersion);

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
  void upgradeVersion(String? currentVersion) {}

  @override
  String usage() => 'upgrade';

  @override
  String description() => '''Upgrades dcli to the latest version.''';

  @override
  List<String> completion(String word) => [];

  @override
  List<Flag> flags() => [];
}
