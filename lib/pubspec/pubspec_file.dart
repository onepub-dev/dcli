import 'package:dshell/script/dependency.dart';
import 'package:dshell/script/script.dart';

import 'pubspec.dart';

///
///Used to read a pubspec.yaml file that is in the
///same directory as the script.
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
  String get version => pubspec.version;
}
