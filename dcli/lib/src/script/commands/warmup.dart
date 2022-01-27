import '../../../dcli.dart';
import '../../util/completion.dart';
import '../command_line_runner.dart';
import '../flags.dart';
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
  int run(List<Flag> selectedFlags, List<String> arguments) {
    String targetPath;

    if (arguments.isEmpty) {
      targetPath = pwd;
    } else if (arguments.length != 1) {
      throw InvalidArgumentsException(
        'Expected a single project path or no project path. '
        'Found ${arguments.length} ',
      );
    } else {
      targetPath = arguments[0];
    }

    _prepareProject(targetPath);
    return 0;
  }

  void _prepareProject(String targetPath) {
    if (!exists(targetPath)) {
      throw InvalidArgumentsException(
          'The project path $targetPath does not exists.');
    }
    if (!isDirectory(targetPath)) {
      throw InvalidArgumentsException('The project path must be a directory.');
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
