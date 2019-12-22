import 'package:dshell/dshell.dart';
import 'package:dshell/functions/touch.dart';
import 'package:dshell/script/dependency.dart';
import 'package:dshell/script/my_yaml.dart';

import 'package:path/path.dart' as p;

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
  static const String filename = 'dependancies.yaml';
  MyYaml _yaml;

  GlobalDependancies() {
    if (!exists(path)) {
      touch(path, create: true);
    }
    _yaml = MyYaml.loadFromFile(path);
  }

  /// Use this ctor for unit testing.
  GlobalDependancies.fromString(String yaml) {
    _yaml = MyYaml.fromString(yaml);
  }

  static String get path => p.join(Settings().dshellPath, filename);

  @override
  MyYaml get yaml => _yaml;

  /// Creates the default global dependancies
  static void createDefault() {
    if (!exists(path)) {
      path.write('dependencies:');

      for (var dep in defaultDependencies) {
        path.append('  ${dep.name}: ${dep.version}');
      }
    }
  }

  static List<Dependency> get defaultDependencies {
    return [
      Dependency('dshell', '^1.0.0'),
      Dependency('args', '^1.5.2'),
      Dependency('path', '^1.6.4'),
    ];
  }
}
