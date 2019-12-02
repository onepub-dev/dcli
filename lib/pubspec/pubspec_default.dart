import 'package:dshell/pubspec/pubspec.dart';
import 'package:dshell/script/dependency.dart';
import 'package:dshell/script/my_yaml.dart';
import 'package:dshell/script/script.dart';

import 'dependencies_mixin.dart';

///
/// If no user defined pubspec exists we need to create
/// a default pubspec with the standard set
/// of dependencies we inject.
class PubSpecDefault extends PubSpec with DependenciesMixin {
  Script _script;

  MyYaml yaml;

  String get name => _script.basename;
  String get version => "1.0.0";

  PubSpecDefault(this._script) {
    yaml = MyYaml.fromString(_default());
  }

  /// Creates default content for a virtual pubspec
  String _default() {
    List<Dependency> dependancies = defaultDepencies;

    List<String> yamlLines = dependancies
        .map((dependancy) => "${dependancy.name}: ${dependancy.version}")
        .toList();

    return '''
name: ${_script.basename}
version: $version
dependencies: 
  ${yamlLines.join("\n  ")}
    ''';
  }

  static List<Dependency> get defaultDepencies {
    return [
      Dependency("dshell", "^1.0.0"),
      Dependency("args", "^1.5.2"),
      Dependency("path", "^1.6.4"),
    ];
  }
}
