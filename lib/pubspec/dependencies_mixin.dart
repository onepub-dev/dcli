import 'package:dshell/script/dependency.dart';
import 'package:dshell/script/my_yaml.dart';
import 'package:yaml/yaml.dart';

mixin DependenciesMixin {
  List<Dependency> _dependencies;

  String get name => yaml.getValue("name");
  String get version => yaml.getValue("version");

  MyYaml get yaml;

  List<Dependency> get dependencies {
    if (_dependencies == null) {
      _dependencies = _extractDependancies(yaml);
    }
    return _dependencies;
  }

  set dependencies(List<Dependency> lDependencies) =>
      this._dependencies = lDependencies;

  List<Dependency> _extractDependancies(MyYaml yaml) {
    List<Dependency> dependancies = List();
    YamlMap map = yaml.getMap("dependencies");

    if (map != null) {
      for (MapEntry entry in map.entries) {
        Dependency dependency =
            Dependency(entry.key as String, entry.value as String);
        dependancies.add(dependency);
      }
    }
    return dependancies;
  }
}
