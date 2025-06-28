/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:dcli/dcli.dart';

import '../script/flags.dart';
import '../util/exceptions.dart';
import '../util/recase.dart';
import 'commands.dart';

///
class VersionCommand extends Command {
  ///
  VersionCommand() : super(_commandName);

  static const String _commandName = 'version';

  @override
  Future<int> run(List<Flag> selectedFlags, List<String> subarguments) async {
    if (subarguments.isNotEmpty) {
      throw InvalidCommandArgumentException(
        "'dcli version' does not take any arguments. Found $subarguments",
      );
    }

    final appname = DCliPaths().dcliName;

    var location = which(appname).path;

    if (location == null) {
      printerr(red('Error: dcli is not on your path. Run "dcli install"'));
    }

    location ??= 'Not installed';
    // expand symlink
    location = File(location).resolveSymbolicLinksSync();

    print(
      green(
        '${ReCase().titleCase(appname)} '
        'Version: ${Settings().version}, Located at: $location',
      ),
    );

    return 0;
  }

  @override
  String description({bool extended = false}) =>
      """Running 'dcli version' displays the dcli version and path.""";

  @override
  String usage() => 'version';

  @override
  List<String> completion(String word) => <String>[];

  @override
  List<Flag> flags() => [];
}
