/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';

import '../script/flags.dart';
import '../util/completion.dart';
import '../util/exceptions.dart';
import 'commands.dart';

/// Implementation for the 'clean' command.
/// The clean command removes all build artifiacts
/// including pubspec.lock, .packages, .dart_tools and
/// any compiled exes.
class CleanCommand extends Command {
  static const _commandName = 'clean';

  ///
  CleanCommand() : super(_commandName);

  /// [arguments] contains path to clean
  @override
  Future<int> run(List<Flag> selectedFlags, List<String> arguments) async {
    String targetPath;

    if (arguments.isEmpty) {
      targetPath = pwd;
    } else if (arguments.length != 1) {
      throw InvalidCommandArgumentException(
        'Expected a single project path or no project path. '
        'Found ${arguments.length} ',
      );
    } else {
      targetPath = arguments[0];
    }

    await _cleanProject(targetPath);
    return 0;
  }

  Future<void> _cleanProject(String targetPath) async {
    if (!exists(targetPath)) {
      throw InvalidCommandArgumentException(
          'The project path $targetPath does not exists.');
    }
    if (!isDirectory(targetPath)) {
      throw InvalidCommandArgumentException(
          'The project path must be a directory.');
    }

    final project = DartProject.fromPath(targetPath);

    print('');
    print(orange('Cleaning ${project.pathToProjectRoot} ...'));
    print('');

    await project.clean();
  }

  @override
  String usage() => 'clean [<project path>]';

  @override
  String description({bool extended = false}) => '''
Removes all build artfiacts.
   If no directory is passed then the current directory is cleaned''';

  @override
  List<String> completion(String word) => completionExpandScripts(word);

  @override
  List<Flag> flags() => [];
}
