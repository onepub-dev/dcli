import '../command_line_runner.dart';
import '../flags.dart';
import '../project_cache.dart';
import 'commands.dart';

/// implementation for the 'cleanall' command.
class CleanAllCommand extends Command {
  static const String _commandName = 'cleanall';

  ///
  CleanAllCommand() : super(_commandName);

  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.isNotEmpty) {
      throw InvalidArguments(
          'The cleanall command takes only no argument. Found: ${arguments.join(',')}');
    }

    ProjectCache().cleanAll();
    return 0;
  }

  @override
  String usage() => 'cleanall';

  @override
  String description() => '''Delete the project cache for all scripts. 
   The script's project cache will be rebuilt when the script is next run.''';

  @override
  List<String> completion(String word) {
    // clean all takes no arguments.
    return <String>[];
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
