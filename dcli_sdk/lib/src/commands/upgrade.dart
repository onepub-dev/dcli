/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:scope/scope.dart';

import '../script/flags.dart';
import '../util/exceptions.dart';
import '../version/version.g.dart';
import 'commands.dart';

/// upgrades dcli by running:
/// pub global active dcli
/// and then preparing all projects.
class UpgradeCommand extends Command {
  static const _commandName = 'upgrade';

  ///
  UpgradeCommand() : super(_commandName);

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
    // ignore: invalid_use_of_visible_for_testing_member
    if (Scope.hasScopeKey(installFromSourceKey) &&
        // the scopes are used to aid with testing hence the
        // need to access a test method.
        // ignore: invalid_use_of_visible_for_testing_member
        Scope.use(installFromSourceKey)) {
      // If we are called from a unit test we do it from source
      PubCache().globalActivateFromSource(
          join(DartProject.self.pathToProjectRoot, '..', 'dcli_sdk'));
    } else {
      /// activate from pub.dev
      PubCache().globalActivate('dcli_sdk', version: packageVersion);
    }
    verbose(() => 'dart pub global activate dcli_sdk finished');

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
