/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:equatable/equatable.dart';

/// Defines a pubspec.yaml dependency.
class DependencyLine extends Equatable {
  /// ctor
  const DependencyLine(this.name, this.line);

  /// reference to the package. Could be a version no., path, git rep....
  final String line;

  /// name of the package.
  final String name;

  ///
  static DependencyLine? fromLine(String line) {
    DependencyLine? dep;

    final parts = line.split(' ');
    if (parts.length == 3) {
      // dep = DependencyLine(parts[1], parts[2]);
    }
    return dep;
  }

  @override
  List<Object?> get props => [name, line];

  @override
  String toString() => '$name: $line';

  ///
  String rehydrate() => toString();
}
