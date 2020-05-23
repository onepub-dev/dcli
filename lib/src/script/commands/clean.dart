import '../../../dshell.dart';
import '../../util/completion.dart';
import '../command_line_runner.dart';

import '../flags.dart';
import '../script.dart';
import '../virtual_project.dart';
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
    var scriptList = arguments;

    if (scriptList.isEmpty) {
      scriptList = find('*.dart').toList();
    }

    if (scriptList.isEmpty) {
      throw InvalidArguments('There are no scripts to clean.');
    } else {
      for (var scriptPath in scriptList) {
        _cleanScript(scriptPath);
      }
    }
    return 0;
  }

  void _cleanScript(String scriptPath) {
    print('');
    print(orange('Cleaning $scriptPath...'));
    print('');
    Script.validate(scriptPath);

    var script = Script.fromFile(scriptPath);

    var project = VirtualProject.create(script);
    project.build();
  }

  @override
  String usage() => 'clean [<script path.dart>, <script path.dart> ...]';

  @override
  String description() =>
      '''Deletes the project cache for each <scriptname.dart> and forces a rebuild of the script's cache.
   If no script is passed then all scripts in the current directory are cleaned.
      ''';

  @override
  List<String> completion(String word) {
    return completionExpandScripts(word);
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
