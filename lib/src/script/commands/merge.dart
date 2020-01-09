import 'package:dshell/dshell.dart';

import '../flags.dart';
import 'commands.dart';

class MergeCommand extends Command {
  static const String NAME = 'merge';

  MergeCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    // TODO: implement run
    return 0;
  }

  @override
  String description() =>
      'Deletes your pubspec.yaml and creates an inline annoation version in your scriptfile. Use this to reduce a project to a single script file.';

  @override
  String usage() => 'merge <script path.dart>';

  @override
  List<String> completion(String word) {
    var dartScripts = find('*.dart', recursive: false).toList();
    var results = <String>[];
    for (var script in dartScripts) {
      if (script.startsWith(word)) {
        results.add(script);
      }
    }
    return results;
  }
}
