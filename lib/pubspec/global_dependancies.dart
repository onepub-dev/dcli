import 'package:dshell/script/dependency.dart';
import 'package:dshell/script/my_yaml.dart';

import 'dependencies_mixin.dart';

///
/// Global dependancies is a file located in ~/.dshell/dependancies.yaml
/// that contains a 'dependencies' section from a pubsec.yaml file.abstract
///
/// The global dependancies allows a user to inject a standard set
/// of dependencies into every script.
///
///

class GlobalDependancies with DependenciesMixin {
  List<Dependency> dependancies = List();
  MyYaml _yaml;

  GlobalDependancies() {
    _yaml = MyYaml.loadFromFile("~/.dshell/dependancies.yaml");
  }

  /// Use this ctor for unit testing.
  GlobalDependancies.fromString(String yaml) {
    _yaml = MyYaml.fromString(yaml);
  }

  @override
  MyYaml get yaml => _yaml;
}
