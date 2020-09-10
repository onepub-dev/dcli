import '../../../dcli.dart';
import '../../util/completion.dart';
import '../command_line_runner.dart';

import '../flags.dart';
import '../dart_project.dart';
import 'commands.dart';

/// implementation for the 'clean' command.
class CleanCommand extends Command {
  static const String _commandName = 'clean';

  ///
  CleanCommand() : super(_commandName);

  /// [arguments] contains a list of scripts to clean or if empty all scripts in the
  /// current directory are cleaned.
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

    _cleanProject(targetPath);
    return 0;
  }

  void _cleanProject(String targetPath) {
    if (!exists(targetPath)) {
      throw InvalidArguments('The project path ${targetPath} does not exists.');
    }
    if (!isDirectory(targetPath)) {
      throw InvalidArguments('The project path must be a directory.');
    }

    var project = DartProject.fromPath(targetPath, search: true);

    print('');
    print(orange('Cleaning ${project.pathToProjectRoot} ...'));
    print('');

    project.clean();
  }

  @override
  String usage() => 'clean [<project path>]';

  @override
  String description() => '''Runs pub upgrade on the given directory.
  If no directory is passed then the current directory is cleaned''';

  @override
  List<String> completion(String word) {
    return completionExpandScripts(word);
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
