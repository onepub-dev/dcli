import 'package:pub_semver/pub_semver.dart';

import '../script/dependency.dart';

import 'pubspec.dart';

/// Manages the virtual pubspec.yaml we create for each script.
class PubSpecVirtual implements PubSpec //with DependenciesMixin {
{
  PubSpec _pubspec;

  ///
  /// Create a virtual pubspec from an existing pubspec
  /// which could have been an default pubspec,
  /// an annotation or an actual file based pubspec.yaml.
  PubSpecVirtual.fromPubSpec(PubSpec sourcePubSpec) {
    _pubspec = sourcePubSpec;
  }

  @override
  set dependencies(List<Dependency> newDependencies) {
    _pubspec.dependencies = newDependencies;
  }

  @override
  List<Dependency> get dependencies => _pubspec.dependencies;

  @override
  String get name => _pubspec.name;

  @override
  Version get version => _pubspec.version;

  @override
  set version(Version version) => _pubspec.version;

  @override
  void saveToFile(String path) {
    _pubspec.saveToFile(path);
  }
}
