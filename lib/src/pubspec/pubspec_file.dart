import 'package:pub_semver/pub_semver.dart';

import '../script/dependency.dart';
import '../script/script.dart';

import 'pubspec.dart';

///
///Used to read a pubspec.yaml file
///
class PubSpecFile implements PubSpec // with DependenciesMixin
{
  PubSpec __pubspec;

  /// creates a pubspec based on the [script]s path.
  PubSpecFile.fromScript(Script script) {
    _fromFile(script.pubSpecPath);
  }

  /// creates a pubspec based on the [path]
  PubSpecFile.fromFile(String path) {
    _fromFile(path);
  }

  void _fromFile(String path) {
    __pubspec = PubSpecImpl.loadFromFile(path);
  }

  @override
  void writeToFile(String path) {
    __pubspec.writeToFile(path);
  }

  @override
  set dependencies(List<Dependency> newDependencies) {
    __pubspec.dependencies = newDependencies;
  }

  @override
  List<Dependency> get dependencies => __pubspec.dependencies;

  @override
  String get name => __pubspec.name;

  @override
  Version get version => __pubspec.version;

  @override
  set version(Version version) => __pubspec.version = version;
}
