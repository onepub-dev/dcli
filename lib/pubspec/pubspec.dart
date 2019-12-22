import 'dart:io';

import 'package:dshell/functions/read.dart';
import 'package:dshell/script/dependency.dart';
import 'package:dshell/util/waitForEx.dart';
import 'package:path/path.dart';
import 'package:pubspec/pubspec.dart' as pub;

///
/// Provides a common interface for access a pubspec content.abstract
///

abstract class PubSpec {
  String get name;
  String get version;

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
  String get version => pubspec.version.toString();

  @override
  set dependencies(List<Dependency> dependencies) {
    var ref = <String, pub.HostedReference>{};

    for (var dependency in dependencies) {
      ref[dependency.name] = pub.HostedReference.fromJson(dependency.version);
    }

    pubspec = pubspec.copy(dependencies: ref);
  }

  @override
  List<Dependency> get dependencies {
    var depends = <Dependency>[];

    var map = pubspec.dependencies;

    for (var name in map.keys) {
      var package = map[name] as pub.HostedReference;

      depends.add(Dependency(name, package.versionConstraint.toString()));
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
