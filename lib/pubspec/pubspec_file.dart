import 'package:dshell/functions/read.dart';
import 'package:dshell/pubspec/pubspec.dart';
import 'package:dshell/script/my_yaml.dart';
import 'package:dshell/script/script.dart';
import 'package:dshell/util/string_as_process.dart';

import 'dependencies_mixin.dart';

///
///Used to read a pubspec.yaml file that is in the
///same directory as the script.
///
class PubSpecFile extends PubSpec with DependenciesMixin {
  // The script this PubSpec is associated with.
  Script _script;
  MyYaml yaml;

  PubSpecFile.fromScript(this._script) {
    List<String> lines = read(this._script.pubSpecPath).toList();
    yaml = MyYaml.fromString(lines.join("\n"));
  }

  PubSpecFile._internal();

  void writeToFile(String path) {
    path.truncate;

    path.write(yaml.toString());
  }

  void injectDefaultPackages() {}
}
