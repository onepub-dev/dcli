import 'package:collection/collection.dart';
import 'package:dshell/dshell.dart';
import 'package:dshell/src/functions/is.dart';

import '../command_line_runner.dart';
import '../flags.dart';
import '../script.dart';
import 'commands.dart';

class SplitCommand extends Command {
  static const String NAME = 'split';

  SplitCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var exitCode = 0;
    if (subarguments.isEmpty) {
      throw InvalidArguments('Split requires a argument <script file.dart>');
    }
    Script.validate(subarguments);
    var script = Script.fromFile(subarguments[0]);

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
      copy(script.pubSpecPath, join(script.path, 'pubspec.yaml'));
      // now we need to disable the @pubspec annotation.
      _replace(script.path, '@pubspec', '@disabled-pubspec');
      print('complete.');
    }

    return exitCode;
  }

  @override
  String description() =>
      'Removes the pubspec annotation from your scripts and saves it to a pubspec.yaml file. Use this option when you project starts to grow.';

  @override
  String usage() => 'split <script path.dart>';

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
