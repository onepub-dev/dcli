import 'package:pub_semver/pub_semver.dart';

import '../script/dependency.dart';
import '../script/script.dart';

import 'pubspec.dart';

///
///Used to read a pubspec.yaml file
///
class PubSpecFile implements PubSpec // with DependenciesMixin
{
  PubSpec pubspec;

  PubSpecFile.fromScript(Script script) {
    _fromFile(script.pubSpecPath);
  }

  PubSpecFile.fromFile(String path) {
    _fromFile(path);
  }

  void _fromFile(String path) {
    pubspec = PubSpecImpl.loadFromFile(path);
  }

  PubSpecFile._internal();

  @override
  void writeToFile(String path) {
    pubspec.writeToFile(path);
  }

  void injectDefaultPackages() {}

  @override
  set dependencies(List<Dependency> newDependencies) {
    pubspec.dependencies = newDependencies;
  }

  @override
  List<Dependency> get dependencies => pubspec.dependencies;

  @override
  String get name => pubspec.name;

  @override
  Version get version => pubspec.version;

  @override
  set version(Version version) => pubspec.version = version;
}
