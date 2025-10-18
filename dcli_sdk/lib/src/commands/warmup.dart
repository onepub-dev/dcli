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

/// implementation for the 'warmup' command
/// which does any work necessary to prepare a project
/// to be run. Essentially this equates to doing a pub get.
class WarmupCommand extends Command {
  static const _commandName = 'warmup';

  ///
  WarmupCommand() : super(_commandName);

  /// [arguments] contains path to prepare
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

    await _prepareProject(targetPath);
    return 0;
  }

  Future<void> _prepareProject(String targetPath) async {
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
    print(orange('Preparing ${project.pathToProjectRoot} ...'));
    print('');

    await project.warmup();
  }

  @override
  String usage() => 'warmup [<project path>]';

  @override
  String description({bool extended = false}) => '''
Runs pub get on the given project.
   If no directory is passed then the current directory is warmed up.''';

  @override
  List<String> completion(String word) => completionExpandScripts(word);

  @override
  List<Flag> flags() => [];
}
