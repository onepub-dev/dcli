import 'package:collection/collection.dart';
import '../../../dshell.dart';
import '../../functions/is.dart';
import '../../util/completion.dart';

import '../command_line_runner.dart';
import '../flags.dart';
import '../script.dart';
import 'commands.dart';

///
class SplitCommand extends Command {
  static const String _commandName = 'split';

  ///
  SplitCommand() : super(_commandName);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var exitCode = 0;
    if (subarguments.isEmpty) {
      throw InvalidArguments('Split requires a argument <script file.dart>.');
    }
    var scriptPath = subarguments[0];
    Script.validate(scriptPath);
    var script = Script.fromFile(scriptPath);

    if (exists(join(script.path, 'pubspec.yaml'))) {
      if (_identical(script)) {
        print('The pubspec.yaml already exists and is upto date');
      } else {
        printerr(
            'A pubspec.yaml already exists in ${script.path}, however it is not up to date');
        printerr('Delete the existing pubspec.yaml and try again.');
        exitCode = 1;
      }
    } else {
      copy(script.pubSpecPath, join(dirname(script.path), 'pubspec.yaml'));
      // now we need to disable the @pubspec annotation.
      replace(script.path, '@pubspec', '@disabled-pubspec');
      print('complete.');
    }

    return exitCode;
  }

  @override
  String description() =>
      '''Removes the pubspec annotation from your scripts and saves it to a pubspec.yaml file. 
   Use this option when you project starts to grow.''';

  @override
  String usage() => 'split <script path.dart>';

  @override
  List<String> completion(String word) {
    return completionExpandScripts(word);
  }

  // checks if the script's pubspec is identical to the
  // pubspec in the local directory
  bool _identical(Script script) {
    var localPubspecPath = canonicalize(join(script.path, 'pubspec.yaml'));

    // check the virtual project has a symlink back to the local pubspec.
    if (isLink(script.pubSpecPath)) {
      var resolved = resolveSymLink(script.pubSpecPath);
      if (resolved == localPubspecPath) {
        return true;
      }
    }

    return _compare(localPubspecPath, script.pubSpecPath);
  }

  bool _compare(String localPubspecPath, String pubSpecPath) {
    var localContent = read(localPubspecPath).toList();
    var virtualContent = read(pubSpecPath).toList();

    return const ListEquality<String>().equals(localContent, virtualContent);
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
