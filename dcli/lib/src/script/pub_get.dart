/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import '../../dcli.dart';
import '../pubspec/dependency.dart';

///
/// runs and retrives the results of calling
/// ```bash
/// pub get
/// ```
/// For the given [DartProject]
///

class PubGet {
  final DartProject _project;

  ///
  PubGet(this._project);

  /// Runs the pub get command against
  /// the project working dir.
  /// Throws [PubGetException].
  /// @Throwing(PubGetException)
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
  final _added = <DependencyLine>[];

  final _removed = <DependencyLine>[];

  ///
  PubGetResult();

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
  /// the pub get exit code.
  final int? exitCode;

  ///
  PubGetException(this.exitCode) : super('dart pub get failed');
}
