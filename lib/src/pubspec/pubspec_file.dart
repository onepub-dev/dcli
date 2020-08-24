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

  /// Reads a pubspec.yaml from the path that  [script] is located in.
  PubSpecFile.fromScript(Script script) {
    _fromFile(script.pathToLocalPubSpec);
  }

  /// Reads a pubspec.yaml located at [path]
  PubSpecFile.fromFile(String path) {
    _fromFile(path);
  }

  void _fromFile(String path) {
    __pubspec = PubSpecImpl.loadFromFile(path);
  }

  /// Saves this [PubSpecFile] to a pubspec.yaml at the given
  /// [path].
  /// The [path] must be a directory not a file name.
  @override
  void saveToFile(String path) {
    __pubspec.saveToFile(path);
  }

  /// Sets the list of dependencies for this pubspec.
  @override
  set dependencies(List<Dependency> newDependencies) {
    __pubspec.dependencies = newDependencies;
  }

  // removed unti pupspec 0.14 is released
  // /// Sets the list of executables for this pubspec.
  // @override
  // List<Executable> get executables {
  //   return __pubspec.executables;
  // }

  /// Returns the set of dependencies contained in this pubspec.
  @override
  List<Dependency> get dependencies => __pubspec.dependencies;

  /// Returns the name field from the pubspec.yaml
  @override
  String get name => __pubspec.name;

  /// Returns the version field from the pubspec.yaml
  @override
  Version get version => __pubspec.version;

  /// Sets the version field for the pubspec.
  /// Call [saveToFile] to update the contents of the pubspec.yaml.
  @override
  set version(Version version) => __pubspec.version = version;
}
