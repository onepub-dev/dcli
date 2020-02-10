import 'dart:io';

import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import '../functions/read.dart';
import '../script/dependency.dart';
import '../util/waitForEx.dart';
import 'package:path/path.dart';
import 'package:pubspec/pubspec.dart' as pub;

///
/// Provides a common interface for access a pubspec content.abstract
///

abstract class PubSpec {
  String get name;
  Version get version;
  set version(Version version);

  /// Saves the pubspec.yaml into the
  /// given directory
  void writeToFile(String directory);

  set dependencies(List<Dependency> newDependencies);
  List<Dependency> get dependencies;

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

class PubSpecImpl implements PubSpec {
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
  List<Dependency> get dependencies {
    var depends = <Dependency>[];

    var map = pubspec.dependencies;

    for (var name in map.keys) {
      var reference = map[name];
      depends.add(Dependency(name, reference));
    }

    return depends;
  }

  factory PubSpecImpl.fromString(String yamlString) {
    var impl = PubSpecImpl._internal();
    impl.pubspec = pub.PubSpec.fromYamlString(yamlString);
    return impl;
  }

  PubSpecImpl._internal();

  /// Saves the pubspec.yaml into the
  /// given directory
  @override
  void writeToFile(String directory) {
    waitForEx<dynamic>(pubspec.save(Directory(dirname(directory))));
  }

  static PubSpec loadFromFile(String path) {
    var lines = read(path).toList();
    return PubSpecImpl.fromString(lines.join('\n'));
  }
}
