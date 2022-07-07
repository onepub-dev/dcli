/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:equatable/equatable.dart';

import 'package:pub_semver/pub_semver.dart';

import 'package:pubspec/pubspec.dart';
import '../../src/pubspec/dep_ref_extension.dart';

/// Defines a pubspec.yaml dependency.
class Dependency extends Equatable {
  /// ctor
  const Dependency(this.name, this.reference);

  /// Creates a dependancy ref from hosted ref.
  Dependency.fromHosted(this.name, String version)
      : reference = HostedReference(VersionConstraint.parse(version));

  ///
  Dependency.fromPath(this.name, String path) : reference = PathReference(path);

  /// reference to the package. Could be a version no., path, git rep....
  final DependencyReference reference;

  /// name of the package.
  final String name;

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
  String toString() => reference.rehydrate(this);

  ///
  String rehydrate() => reference.rehydrate(this);
}
