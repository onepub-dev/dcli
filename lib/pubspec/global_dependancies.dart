import 'package:dshell/functions/env.dart';
import 'package:dshell/functions/is.dart';
import 'package:dshell/functions/touch.dart';
import 'package:dshell/script/my_yaml.dart';

import 'package:path/path.dart' as p;

import '../settings.dart';
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
  static const String filename = "dependancies.yaml";
  MyYaml _yaml;

  GlobalDependancies() {
    String path = p.join(Settings().configRootPath, filename);

    if (!exists(path)) {
      touch(path, create: true);
    }
    _yaml = MyYaml.loadFromFile(path);
  }

  /// Use this ctor for unit testing.
  GlobalDependancies.fromString(String yaml) {
    _yaml = MyYaml.fromString(yaml);
  }

  @override
  MyYaml get yaml => _yaml;
}
