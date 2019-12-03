import 'package:dshell/script/dependency.dart';
import 'package:dshell/script/my_yaml.dart';

import 'package:dshell/util/string_as_process.dart';

///
/// Provides a common interface for access a pubspec content.abstract
///

abstract class PubSpec {
  List<Dependency> get dependencies;
  set dependencies(List<Dependency> _dependancies);

  MyYaml get yaml;

  String get name;
  String get version;

  void writeToFile(String path) {
    path.truncate;

    path.write(yaml.content);
  }

  void replaceDependancies(List<Dependency> resolved) {
    dependencies = resolved;
  }
}
