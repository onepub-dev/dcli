/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import '../../dcli.dart';

///
/// runs and retrives the results of calling
/// ```
/// pub upgrade
/// ```
/// For the given [DartProject]
///

class PubUpgrade {
  ///
  PubUpgrade(this._project);

  final DartProject _project;

  /// Runs the pub get command against
  /// the project working dir.
  PubUpgradeResult run({bool compileExecutables = true}) {
    final result = PubUpgradeResult();
    try {
      // pub get MUST be run from the directory which contains
      //  the pubspec.yaml file.
      DartSdk().runPubGet(
        _project.pathToProjectRoot,
        compileExecutables: compileExecutables,
        progress: Progress(result._processLine, stderr: _println),
      );

      return result;
    } on RunException catch (e) {
      verbose(() => 'pub upgrade exeception: $e');
      throw PubUpgradeException(e.exitCode);
    }
  }

  void _println(String? line) {
    verbose(() => 'pub get: $line');
    print(line);
  }
}

/// results from running pub get.
/// we parse lines of interest.
class PubUpgradeResult {
  ///
  PubUpgradeResult();

  final List<DependencyLine> _added = <DependencyLine>[];
  final List<DependencyLine> _removed = <DependencyLine>[];

  void _processLine(String line) {
    print(line);
    if (line.startsWith('+ ')) {
      final dep = DependencyLine.fromLine(line);
      if (dep != null) {
        _added.add(dep);
      }
    }

    if (line.startsWith('- ')) {
      final dep = DependencyLine.fromLine(line);
      if (dep != null) {
        _removed.add(dep);
      }
    }
  }

  /// list of dependency that pub get added
  List<DependencyLine> get added => _added;

  /// list of dependency that pub get removed
  List<DependencyLine> get removed => _removed;
}

///

class PubUpgradeException extends DCliException {
  ///
  PubUpgradeException(this.exitCode) : super('dart pub upgrade failed');

  /// the pub get exit code.
  final int? exitCode;
}
