import 'package:equatable/equatable.dart';

import 'package:pub_semver/pub_semver.dart';

import 'package:pubspec2/pubspec2.dart';
import '../../src/pubspec/dep_ref_extension.dart';

/// Defines a pubspec.yaml dependency.
class Dependency extends Equatable {
  /// name of the package.
  final String name;

  /// reference to the package. Could be a version no., path, git rep....
  final DependencyReference reference;

  /// ctor
  const Dependency(this.name, this.reference);

  /// Creates a dependancy ref from hosted ref.
  Dependency.fromHosted(this.name, String version)
      : reference = HostedReference(VersionConstraint.parse(version));

  ///
  Dependency.fromPath(this.name, String path) : reference = PathReference(path);

  ///
  static Dependency? fromLine(String line) {
    Dependency? dep;

    final parts = line.split(' ');
    if (parts.length == 3) {
      // dep = Dependency(parts[1], parts[2]);
    }
    return dep;
  }

  @override
  List<Object?> get props => [name, reference];

  @override
  String toString() {
    return reference.rehydrate(this);
  }

  ///
  String rehydrate() {
    return reference.rehydrate(this);
  }
}
