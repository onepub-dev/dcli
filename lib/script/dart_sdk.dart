import 'dart:cli';
import "dart:io";
import 'package:dshell/script/script.dart';
import 'package:dshell/util/for_each.dart';
import 'package:dshell/util/runnable_process.dart';
import 'package:path/path.dart' as p;

import 'std_log.dart';

/// The [DartSdk] implementation where the Dart sdk directory is detected.
class DartSdk {
  static DartSdk _self;

  /// Path of Dart SDK
  String _sdkPath;

  String _version;

  factory DartSdk() {
    if (_self == null) {
      _self = DartSdk._internal(_detect());
    }

    return _self;
  }

  DartSdk._internal(String sdkPath) {
    _sdkPath = sdkPath;

    StdLog.stderr(
        'dscript: Dart SDK found at ${_sdkPath} with version ${version}',
        LogLevel.verbose);
  }

  String get dartPath => p.join(_sdkPath, 'bin', 'dart');

  String get pubGetPath => p.join(_sdkPath, 'bin', 'pub');

  String get dart2NativePath => p.join(_sdkPath, 'bin', 'dart2native');

  ForEach runDart2Native(
      Script script, String outputDir, String workingDirectory) {
    List<String> runArgs = List();
    runArgs.add(script.scriptname);
    runArgs.add("--output=${outputDir}/${script.basename}");

    return run(dart2NativePath, runArgs, workingDirectory);
  }

  ForEach runPubGet(String workingDirectory) {
    return run(pubGetPath, ['get'], workingDirectory);
  }

  /// Runs a dart application returning all the accumulated
  /// stdout as a single string.
  /// Throws a RunException on failure
  /// the project working dir.
  ForEach run(String processPath, List<String> args, String workingDirectory) {
    ForEach forEach;

    try {
      forEach = ForEach();

      RunnableProcess runnable = RunnableProcess.fromList(processPath, args,
          workingDirectory: workingDirectory);
      runnable.start();
      runnable.processUntilExit((line) => forEach.addToStdout(line),
          (line) => forEach.addToStderr(line));
    } finally {
      forEach.close();
    }
  }

  static String _detect() {
    String executable = Platform.executable;
    final String s = Platform.pathSeparator;

    if (!executable.contains(s)) {
      if (Platform.isLinux) {
        executable = Link("/proc/$pid/exe").resolveSymbolicLinksSync();
      }
    }

    final file = File(executable);
    if (!file.existsSync()) {
      throw dartSdkNotFound;
    }

    Directory parent = file.absolute.parent;
    parent = parent.parent; // TODO What if this does not exist?

    final String sdkPath = parent.path;
    final String dartApi = "$sdkPath${s}include${s}dart_api.h";
    if (!File(dartApi).existsSync()) {
      throw Exception('Cannot find Dart SDK!');
    }

    return sdkPath;
  }

  String get version {
    if (_version == null) {
      final ProcessResult res =
          waitFor<ProcessResult>(Process.run(dartPath, <String>['--version']));
      if (res.exitCode != 0) {
        throw Exception('Failed!');
      }

      String resultString = res.stderr as String;

      _version =
          resultString.substring('Dart VM version: '.length).split(' ').first;
    }

    return _version;
  }
}

final Exception dartSdkNotFound = Exception('Dart SDK not found!');
