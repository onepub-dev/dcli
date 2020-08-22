import 'package:collection/collection.dart';
import '../../../dcli.dart';
import '../../functions/is.dart';
import '../../util/completion.dart';

import '../command_line_runner.dart';
import '../flags.dart';
import '../script.dart';
import '../virtual_project.dart';
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
        /// there is already a pubspec. Nothing to do here.
        print('The pubspec.yaml already exists and is upto date');
      } else {
        printerr(
            'A pubspec.yaml already exists in ${script.path}, however it is not up to date');
        printerr('Delete the existing pubspec.yaml and try again.');
        exitCode = 1;
      }
    } else {
      /// make certain the virtual project exists before we try to split it.
      var project = VirtualProject.createOrLoad(script);

      if (project.pubspecLocation == PubspecLocation.traditional) {
        print(
            'This appears to be a traditional dart project and already has a pubspec located at: ${project.projectPubspecPath}');
        exitCode = 1;
      }

      if (project.pubspecLocation == PubspecLocation.local) {
        print(
            'This script already has a local pubspec located at: ${project.projectPubspecPath}');
        exitCode = 1;
      }

      if (exitCode == 0) {
        /// We are going to do the split!
        copy(project.projectPubspecPath,
            join(dirname(script.path), 'pubspec.yaml'));
        // now we need to disable the @pubspec annotation (if the script has one.)
        if (project.pubspecLocation == PubspecLocation.annotation) {
          replace(script.path, '@pubspec', '@disabled-pubspec');
        }
        print('complete.');
      }
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
    if (isLink(script.localPubSpecPath)) {
      var resolved = resolveSymLink(script.localPubSpecPath);
      if (resolved == localPubspecPath) {
        return true;
      }
    }

    return _compare(localPubspecPath, script.localPubSpecPath);
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
