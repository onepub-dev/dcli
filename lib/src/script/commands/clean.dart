import 'package:dshell/dshell.dart';

import '../../settings.dart';
import '../command_line_runner.dart';
import '../flags.dart';
import '../script.dart';
import '../virtual_project.dart';
import 'commands.dart';

class CleanCommand extends Command {
  static const String NAME = 'clean';

  CleanCommand() : super(NAME);

  /// [arguments] contains a list of scripts to clean or if empty all scripts in the
  /// current directory are cleaned.
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    var scriptList = arguments;

    if (scriptList.isEmpty) {
      scriptList = find('*.dart').toList();
    }

    if (scriptList.isEmpty) {
      printerr('There are no scripts to clean.');
    } else {
      for (var scriptPath in scriptList) {
        cleanScript(scriptPath);
      }
    }
    return 0;
  }

  void cleanScript(String scriptPath) {
    print('');
    print(orange('Cleaning $scriptPath...'));
    print('');
    Script.validate(scriptPath);

    var script = Script.fromFile(scriptPath);

    var project = VirtualProject(Settings().dshellCachePath, script);

    project.clean();
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
    var dartScripts = find('*.dart', recursive: false).toList();
    var results = <String>[];
    if (word.isEmpty) {
      results = dartScripts;
    } else {
      for (var script in dartScripts) {
        if (script.startsWith(word)) {
          results.add(script);
        }
      }
    }

    return results;
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
