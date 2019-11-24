import 'dart:async';
import 'dart:convert';

import 'dart_sdk.dart';
import 'project.dart';

///
/// runs and retrives the results of calling
/// ```
/// pub get
/// ```
/// for the virtual package we build for the script we are going to run.
///

class PubGet {
  final DartSdk dartSdk;
  final Project project;

  PubGet(this.dartSdk, this.project);

  /// Runs the pub get command against
  /// the project working dir.
  Future<PubGetResult> run() async {
    try {
      String result = DartSdk().runPubGet(project.projectCacheDir);

      return PubGetResult(result);
    } on DartRunException catch (e) {
      throw PubGetException(e.exitCode, e.stdout, e.stderr);
    }
  }
}

class DepInfo {
  final String name;

  final String version;

  const DepInfo(this.name, this.version);
}

class PubGetResult {
  final String outlog;

  PubGetResult(this.outlog);

  List<DepInfo> get added => LineSplitter()
      .convert(outlog)
      .where((String line) => line.startsWith('+ '))
      .map((String line) => line.split(' '))
      .where((List<String> parts) => parts.length == 3)
      .map((List<String> parts) => DepInfo(parts[1], parts[2]))
      .toList();

  List<DepInfo> get removed => LineSplitter()
      .convert(outlog)
      .where((String line) => line.startsWith('- '))
      .map((String line) => line.split(' '))
      .where((List<String> parts) => parts.length == 3)
      .map((List<String> parts) => DepInfo(parts[1], parts[2]))
      .toList();
}

class PubGetException {
  final int exitCode;

  final String stdout;

  final String stderr;

  PubGetException(this.exitCode, this.stdout, this.stderr);
}
