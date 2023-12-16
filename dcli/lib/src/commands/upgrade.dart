/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:scope/scope.dart';

import '../../dcli.dart';
import '../script/command_line_runner.dart';
import '../version/version.g.dart';
import 'commands.dart';
import 'install.dart';

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
  Future<int> run(List<Flag> selectedFlags, List<String> arguments) async {
    if (arguments.isNotEmpty) {
      throw InvalidCommandArgumentException(
          'dcli upgrade does not take any arguments.');
    }

    final currentVersion = Settings().version;

    print(red('Upgrading dcli...'));
    print('Current version $currentVersion');
    // now activate dcli.
    if (Scope.hasScopeKey(InstallCommand.activateFromSourceKey) &&
        Scope.use(InstallCommand.activateFromSourceKey) == true) {
      // If we are called from a unit test we do it from source
      PubCache().globalActivateFromSource(DartProject.self.pathToProjectRoot);
    } else {
      /// activate from pub.dev
      PubCache().globalActivate('dcli', version: packageVersion);
    }
    verbose(() => 'dart pub global activate dcli finished');

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
  String description({bool extended = false}) =>
      '''Upgrades dcli to the latest version.''';

  @override
  List<String> completion(String word) => [];

  @override
  List<Flag> flags() => [];
}
