
import 'dart_sdk.dart';
import 'dependency.dart';
import 'project.dart';
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
  PubGetResult run() {
    PubGetResult result = PubGetResult();
    try {
      DartSdk().runPubGet(project.path).forEach(
          (line) => result.processLine(line),
          stderr: (line) => print(line));

      return result;
    } on RunException catch (e) {
      throw PubGetException(e.exitCode);
    }
  }
}

class PubGetResult {
  List<Dependency> _added = List();
  List<Dependency> _removed = List();

  PubGetResult();

  void processLine(String line) {
    print(line);
    if (line.startsWith('+ ')) {
      Dependency dep = Dependency.fromLine(line);
      if (dep != null) {
        _added.add(dep);
      }
    }

    if (line.startsWith('- ')) {
      Dependency dep = Dependency.fromLine(line);
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
