import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/completion.dart';

import '../flags.dart';
import 'commands.dart';

class MergeCommand extends Command {
  static const String NAME = 'merge';

  MergeCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    //var exitCode = 0;

    printerr('merge is not currently supported');
    return 1;
    /*
    if (subarguments.isEmpty) {
      throw InvalidArguments('Merge requires a argument <script file.dart>');
    }
    Script.validate(subarguments);
    var script = Script.fromFile(subarguments[0]);

    // is there a local pubspec
    var localPubspecPath = join(script.path, 'pubspec.yaml');
    if (!exists(localPubspecPath)) {
      printerr(
          "The script doesn't have a local pubspec.yaml at ${absolute(localPubspecPath)}");
      exitCode = 1;
    } else {
      // we have a local pubspec so lets merge it.
      var localPubspecFile = PubSpecFile.fromFile(localPubspecPath);

      // re-enable the pubspec annotation if 'split' had previously
      // disabled it.
      _replace(script.path, '@disabled-pubspec', '@pubspec');

      // Now check that it is upto date.
      var annotation = PubSpecAnnotation.fromScript(script);
      if (!annotation.exists()) {
        // the script doesn't currently have an annotation
        // We only need to create a new one if the local pubspec
        // differs from what the current default pubspec  should be.
      } else {
        // we have a a pubspec annotation.
        // we now need to determine if we need to update it.
        if (PubSpec.equals(localPubspecFile.pubspec, annotation.pubspec)) {
          delete(localPubspecPath);
        } else {
          // the existing annotation isn't upto date so we need to replace it.

        }
      }
    }

    return exitCode;
    */
  }

  @override
  String description() =>
      '''Deletes your pubspec.yaml and creates an inline annoation version in your scriptfile. 
   Use this to reduce a project to a single script file.''';

  @override
  String usage() => 'merge <script path.dart>';

  @override
  List<String> completion(String word) {
    return completion_expand_scripts(word);
  }

/*
  void _replace(String path, String existing, String replacement) {
    var tmp = '$path.tmp';
    if (exists(tmp)) {
      delete(tmp);
    }
    read(path).forEach((line) {
      line = line.replaceFirst(existing, replacement);
      tmp.append(line);
    });
    move(path, '$path.bak');
    move(tmp, path);
    delete('$path.bak');
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
// */
//   bool _compare(String localPubspecPath, String pubSpecPath) {
//     var localContent = read(localPubspecPath).toList();
//     var virtualContent = read(pubSpecPath).toList();

//     return const ListEquality<String>().equals(localContent, virtualContent);
//   }

  @override
  List<Flag> flags() {
    return [];
  }
}
