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

  void writeToFile(String path);

  set dependencies(List<Dependency> newDependencies);
  List<Dependency> get dependencies;
}

class PubSpecImpl implements PubSpec {
  pub.PubSpec pubspec;

  String get name => pubspec.name;
  String get version => pubspec.version.toString();

  set dependencies(List<Dependency> dependencies) {
    Map<String, pub.HostedReference> ref = Map();

    for (Dependency dependency in dependencies) {
      ref[dependency.name] = pub.HostedReference.fromJson(dependency.version);
    }

    pubspec = pubspec.copy(dependencies: ref);
  }

  List<Dependency> get dependencies {
    List<Dependency> depends = List();

    Map<String, pub.DependencyReference> map = pubspec.dependencies;

    for (String name in map.keys) {
      pub.HostedReference package = map[name] as pub.HostedReference;

      depends.add(Dependency(name, package.versionConstraint.toString()));
    }

    return depends;
  }

  factory PubSpecImpl.fromString(String yamlString) {
    PubSpecImpl impl = PubSpecImpl._internal();
    impl.pubspec = pub.PubSpec.fromYamlString(yamlString);
    return impl;
  }

  PubSpecImpl._internal();

  void writeToFile(String path) {
    waitForEx<dynamic>(pubspec.save(Directory(dirname(path))));
  }

  static PubSpec loadFromFile(String path) {
    List<String> lines = read(path).toList();
    return PubSpecImpl.fromString(lines.join("\n"));
  }
}
