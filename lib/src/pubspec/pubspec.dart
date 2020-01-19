import 'dart:io';

import 'package:dshell/src/script/command_line_runner.dart';
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
}

class PubSpecImpl implements PubSpec {
  pub.PubSpec pubspec;

  @override
  String get name => pubspec.name;
  @override
  Version get version => pubspec.version;

  @override
  set version(Version version) => pubspec.copy(version: version);

  @override
  set dependencies(List<Dependency> dependencies) {
    var ref = <String, pub.DependencyReference>{};

    for (var dependency in dependencies) {
      if (dependency.isPath) {
        ref[dependency.name] = pub.PathReference(dependency.path);
      } else {
        ref[dependency.name] = pub.HostedReference.fromJson(dependency.version);
      }
    }

    pubspec = pubspec.copy(dependencies: ref);
  }

  @override
  List<Dependency> get dependencies {
    var depends = <Dependency>[];

    var map = pubspec.dependencies;

    for (var name in map.keys) {
      var package = map[name];

      if (package is pub.HostedReference) {
        depends.add(Dependency(name, package.versionConstraint.toString()));
      } else if (package is pub.PathReference) {
        depends.add(Dependency.fromPath(name, package.path));
      } else {
        throw InvalidArguments(
            'Unexpected Dependency type ${package.runtimeType}');
      }
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
