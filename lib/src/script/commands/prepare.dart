import '../../../dcli.dart';
import '../../util/completion.dart';
import '../command_line_runner.dart';

import '../flags.dart';
import '../dart_project.dart';
import 'commands.dart';

/// implementation for the 'prepare' command
/// which does any work necessary to prepare a projects
/// to be run. Essentially this equates to doing a pub get.
class PrepareCommand extends Command {
  static const String _commandName = 'prepare';

  ///
  PrepareCommand() : super(_commandName);

  /// [arguments] contains path to prepare
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    String targetPath;

    if (arguments.isEmpty) {
      targetPath = pwd;
    } else if (arguments.length != 1) {
      throw InvalidArguments(
          'Expected a single project path or no project path. Found ${arguments.length} ');
    } else {
      targetPath = arguments[0];
    }

    _prepareProject(targetPath);
    return 0;
  }

  void _prepareProject(String targetPath) {
    if (!exists(targetPath)) {
      throw InvalidArguments('The project path ${targetPath} does not exists.');
    }
    if (!isDirectory(targetPath)) {
      throw InvalidArguments('The project path must be a directory.');
    }

    var project = DartProject.fromPath(targetPath, search: true);

    print('');
    print(orange('Preparinging ${project.pathToProjectRoot} ...'));
    print('');

    project.prepare();
  }

  @override
  String usage() => 'prepare [<project path>]';

  @override
  String description() => '''Runs pub upgrade on the given directory.
   If no directory is passed then the current directory is prepared.''';

  @override
  List<String> completion(String word) {
    return completionExpandScripts(word);
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
