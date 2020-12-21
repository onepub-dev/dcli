import '../../dcli.dart';
import '../pubspec/dependency.dart';
import '../util/progress.dart';
import '../util/runnable_process.dart';
import 'dart_project.dart';
import 'dart_sdk.dart';

///
/// runs and retrives the results of calling
/// ```
/// pub get
/// ```
/// for the virtual package we build for the script we are going to run.
///

class PubGet {
  final DartProject _project;

  ///
  PubGet(this._project);

  /// Runs the pub get command against
  /// the project working dir.
  PubGetResult run({bool compileExecutables = true}) {
    final result = PubGetResult();
    try {
      // pub get MUST be run from the directory which contains the pubspec.yaml file.
      DartSdk().runPubGet(_project.pathToProjectRoot,
          compileExecutables: compileExecutables,
          progress:
              Progress((line) => result._processLine(line), stderr: _println));

      return result;
    } on RunException catch (e) {
      Settings().verbose('pub get exeception: $e');
      throw PubGetException(e.exitCode);
    }
  }

  void _println(String line) {
    Settings().verbose('pubget: $line');
    print(line);
  }
}

/// results from running pub get.
/// we parse lines of interest.
class PubGetResult {
  final List<Dependency> _added = <Dependency>[];
  final List<Dependency> _removed = <Dependency>[];

  ///
  PubGetResult();

  void _processLine(String line) {
    print(line);
    if (line.startsWith('+ ')) {
      final dep = Dependency.fromLine(line);
      if (dep != null) {
        _added.add(dep);
      }
    }

    if (line.startsWith('- ')) {
      final dep = Dependency.fromLine(line);
      if (dep != null) {
        _removed.add(dep);
      }
    }
  }

  /// list of dependency that pub get added
  List<Dependency> get added => _added;

  /// list of dependency that pub get removed
  List<Dependency> get removed => _removed;
}

///

class PubGetException {
  /// the pub get exit code.
  final int exitCode;

  ///
  PubGetException(this.exitCode);
}
