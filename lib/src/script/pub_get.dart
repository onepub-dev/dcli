import 'virtual_project.dart';
import '../util/progress.dart';

import 'dart_sdk.dart';
import 'dependency.dart';
import '../util/runnable_process.dart';

///
/// runs and retrives the results of calling
/// ```
/// pub get
/// ```
/// for the virtual package we build for the script we are going to run.
///

class PubGet {
  final DartSdk dartSdk;
  final VirtualProject project;

  PubGet(this.dartSdk, this.project);

  /// Runs the pub get command against
  /// the project working dir.
  PubGetResult run({bool compileExecutables = true}) {
    var result = PubGetResult();
    try {
      DartSdk().runPubGet(project.path,compileExecutables : compileExecutables ,
          progress: Progress((line) => result.processLine(line),
              stderr: (line) => print(line)));

      return result;
    } on RunException catch (e) {
      throw PubGetException(e.exitCode);
    }
  }
}

class PubGetResult {
  final List<Dependency> _added = <Dependency>[];
  final List<Dependency> _removed = <Dependency>[];

  PubGetResult();

  void processLine(String line) {
    print(line);
    if (line.startsWith('+ ')) {
      var dep = Dependency.fromLine(line);
      if (dep != null) {
        _added.add(dep);
      }
    }

    if (line.startsWith('- ')) {
      var dep = Dependency.fromLine(line);
      if (dep != null) {
        _removed.add(dep);
      }
    }
  }

  List<Dependency> get added => _added;

  List<Dependency> get removed => _removed;
}

class PubGetException {
  final int exitCode;

  PubGetException(this.exitCode);
}
