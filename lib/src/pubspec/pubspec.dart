import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dcli/src/util/wait_for_ex.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec/pubspec.dart' as pub;

import '../../dcli.dart';
import '../script/script.dart';
import 'dependency.dart';

///
///Used to read a pubspec.yaml file
///
class PubSpec {
  /// the wrapped pubspec.
  pub.PubSpec pubspec;

  /// Returns the name field from the pubspec.yaml
  String get name => pubspec.name;

  /// Returns the version field from the pubspec.yaml
  Version get version => pubspec.version;

  /// Sets the version field for the pubspec.
  /// Call [saveToFile] to update the contents of the pubspec.yaml.
  set version(Version version) => pubspec = pubspec.copy(version: version);
  List<Executable> _executables;

  /// Get the list of exectuables
  List<Executable> get executables {
    if (_executables == null) {
      _executables = <Executable>[];
      for (final key in pubspec.executables.keys) {
        _executables.add(Executable(key, pubspec.executables[key].scriptPath));
      }
    }

    return List.unmodifiable(_executables);
  }

  /// Sets the map of dependencies for this pubspec.
  set dependencies(Map<String, Dependency> dependencies) {
    final ref = <String, pub.DependencyReference>{};

    for (final name in dependencies.keys) {
      ref[name] = dependencies[name].reference;
    }

    pubspec = pubspec.copy(dependencies: ref);
  }

  /// Returns an unmodifiable map of the dependencies
  /// If you need to update the map pass a new map
  /// with the updated values.
  Map<String, Dependency> get dependencies {
    final depends = <String, Dependency>{};

    final map = pubspec.dependencies;

    for (final name in map.keys) {
      final reference = map[name];
      depends.putIfAbsent(name, () => Dependency(name, reference));
    }

    return Map.unmodifiable(depends);
  }

  /// Sets the list of dependencies for this pubspec.
  set dependencyOverrides(Map<String, Dependency> dependencies) {
    final ref = <String, pub.DependencyReference>{};

    for (final name in dependencies.keys) {
      ref[name] = dependencies[name].reference;
    }

    pubspec = pubspec.copy(dependencyOverrides: ref);
  }

  /// Returns an unmodifiable map of the dependency overrides
  /// If you need to update the map pass a new map
  /// with the updated values.
  Map<String, Dependency> get dependencyOverrides {
    final depends = <String, Dependency>{};

    final map = pubspec.dependencyOverrides;

    for (final name in map.keys) {
      final reference = map[name];
      depends.putIfAbsent(name, () => Dependency(name, reference));
    }

    return Map.unmodifiable(depends);
  }

  PubSpec._internal();

  /// Reads a pubspec.yaml from the path that  [script] is located in.
  PubSpec.fromScript(Script script) {
    _fromFile(script.pathToPubSpec);
  }

  /// Reads a pubspec.yaml located at [path]
  PubSpec.fromFile(String path) {
    _fromFile(path);
  }

  /// parses a pubspec from a yaml string.
  factory PubSpec.fromString(String yamlString) {
    final impl = PubSpec._internal();
    impl.pubspec = pub.PubSpec.fromYamlString(yamlString);
    return impl;
  }

  void _fromFile(String path) {
    final lines = read(path).toList();

    pubspec = pub.PubSpec.fromYamlString(lines.join('\n'));
  }

  /// Saves this [PubSpec] to a pubspec.yaml at the given
  /// [path].
  /// The [path] must be a directory not a file name.
  void saveToFile(String path) {
    waitForEx<dynamic>(pubspec.save(Directory(dirname(path))));
  }

  /// Compares two pubspec to see if they have the same content.
  static bool equals(PubSpec lhs, PubSpec rhs) {
    if (lhs.name != rhs.name) return false;

    // if (lhs.author != rhs.author) return false;

    if (lhs.version != rhs.version) return false;

    // if (lhs.homepage != rhs.homepage) return false;

    // if (lhs.documentation != rhs.documentation) return false;
    // if (lhs.description != rhs.description) return false;
    // if (lhs.publishTo != rhs.publishTo) return false;
    // if (lhs.environment != rhs.environment) return false;

    if (!const MapEquality<String, Dependency>()
        .equals(lhs.dependencies, rhs.dependencies)) return false;

    return true;
  }

  static pub.PathReference createPathReference(String path) {
    return pub.PathReference.fromJson(<String, String>{'path': path});
  }
}

class Executable {
  String name;

  /// path of the script relative to the pacakge root.
  String pathToScript;

  Executable(this.name, this.pathToScript);
}
