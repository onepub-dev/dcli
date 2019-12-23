import '../script/dependency.dart';
import '../script/my_yaml.dart';

mixin DependenciesMixin {
  List<Dependency> _dependencies;

  String get name => yaml.getValue('name');
  String get version => yaml.getValue('version');

  MyYaml get yaml;

  List<Dependency> get dependencies {
    _dependencies ??= _extractDependancies(yaml);
    return _dependencies;
  }

  set dependencies(List<Dependency> lDependencies) =>
      _dependencies = lDependencies;

  List<Dependency> _extractDependancies(MyYaml yaml) {
    var dependancies = <Dependency>[];
    var map = yaml.getMap('dependencies');

    if (map != null) {
      for (var entry in map.entries) {
        var dependency = Dependency(entry.key as String, entry.value as String);
        dependancies.add(dependency);
      }
    }
    return dependancies;
  }
}
