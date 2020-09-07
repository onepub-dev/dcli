import 'dart:io';

import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:path/path.dart';
import 'package:pubspec/pubspec.dart' as pub;

import '../functions/read.dart';
import '../script/dependency.dart';
import '../util/wait_for_ex.dart';

///
/// Provides a common interface for access a pubspec content.abstract
///

abstract class PubSpec {
  /// name of the project
  String get name;

  /// project version.
  Version get version;
  set version(Version version);

  /// Saves the pubspec.yaml into the
  /// given directory
  void saveToFile(String directory);

  /// sets the list of dependencies in this pubspec.yaml
  set dependencies(List<Dependency> newDependencies);

  /// returns the list of dependencies in this pubspec.yaml
  List<Dependency> get dependencies;

  List<Dependency> get dependencyOverrides;

  List<Executable> get executables;

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

    if (!const ListEquality<Dependency>()
        .equals(lhs.dependencies, rhs.dependencies)) return false;

    return true;
  }
}

/// provides base implementation for PubSpec.
class PubSpecImpl implements PubSpec {
  /// the wrapped pubspec.
  pub.PubSpec pubspec;

  @override
  String get name => pubspec.name;
  @override
  Version get version => pubspec.version;

  @override
  set version(Version version) => pubspec = pubspec.copy(version: version);

  @override
  set dependencies(List<Dependency> dependencies) {
    var ref = <String, pub.DependencyReference>{};

    for (var dependency in dependencies) {
      ref[dependency.name] = dependency.reference;
    }

    pubspec = pubspec.copy(dependencies: ref);
  }

  @override
  List<Dependency> get dependencyOverrides {
    var depends = <Dependency>[];

    var map = pubspec.dependencyOverrides;

    for (var name in map.keys) {
      var reference = map[name];
      depends.add(Dependency(name, reference));
    }

    return depends;
  }

  @override
  List<Dependency> get dependencies {
    var depends = <Dependency>[];

    var map = pubspec.dependencies;

    for (var name in map.keys) {
      var reference = map[name];
      depends.add(Dependency(name, reference));
    }

    return depends;
  }

  List<Executable> _executables;
  @override
  List<Executable> get executables {
    if (_executables == null) {
      _executables = <Executable>[];
      for (var key in pubspec.executables.keys) {
        _executables.add(Executable(key, pubspec.executables[key].scriptPath));
      }
    }
    return _executables;
  }

  /// parses a pubspec from a yaml string.
  factory PubSpecImpl.fromString(String yamlString) {
    var impl = PubSpecImpl._internal();
    impl.pubspec = pub.PubSpec.fromYamlString(yamlString);
    return impl;
  }

  PubSpecImpl._internal();

  /// Saves the pubspec.yaml into the
  /// given directory
  @override
  void saveToFile(String directory) {
    waitForEx<dynamic>(pubspec.save(Directory(dirname(directory))));
  }

  /// reads a pubspec.yaml.
  static PubSpec loadFromFile(String path) {
    var lines = read(path).toList();
    return PubSpecImpl.fromString(lines.join('\n'));
  }
}

class Executable {
  String name;

  /// path of the script relative to the pacakge root.
  String pathToScript;

  Executable(this.name, this.pathToScript);
}
