/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
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
  ///
  WarmupCommand() : super(_commandName);
  static const String _commandName = 'warmup';

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

     project.warmup();
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
