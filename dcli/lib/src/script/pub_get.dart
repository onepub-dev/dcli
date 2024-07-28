/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import '../../dcli.dart';
import '../pubspec/dependency.dart';

///
/// runs and retrives the results of calling
/// ```
/// pub get
/// ```
/// For the given [DartProject]
///

class PubGet {
  ///
  PubGet(this._project);

  final DartProject _project;

  /// Runs the pub get command against
  /// the project working dir.
  PubGetResult run({bool compileExecutables = true}) {
    final result = PubGetResult();
    try {
      // pub get MUST be run from the directory which contains
      //  the pubspec.yaml file.
      DartSdk().runPubGet(
        _project.pathToProjectRoot,
        compileExecutables: compileExecutables,
        progress: Progress(result._processLine, stderr: _printerr),
      );

      return result;
    } on RunException catch (e) {
      verbose(() => 'pub get exeception: $e');
      throw PubGetException(e.exitCode);
    }
  }

  void _printerr(String? line) {
    verbose(() => 'pub get: $line');
    printerr(line);
  }
}

/// results from running pub get.
/// we parse lines of interest.
class PubGetResult {
  ///
  PubGetResult();

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

class PubGetException extends DCliException {
  ///
  PubGetException(this.exitCode) : super('dart pub get failed');

  /// the pub get exit code.
  final int? exitCode;
}
