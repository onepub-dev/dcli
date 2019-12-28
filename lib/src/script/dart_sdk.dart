import 'dart:cli';
import 'dart:io';
import '../../dshell.dart';
import 'script.dart';
import '../util/progress.dart';
import '../util/runnable_process.dart';
import 'package:path/path.dart' as p;

import 'std_log.dart';

/// The [DartSdk] implementation where the Dart sdk directory is detected.
class DartSdk {
  static DartSdk _self;

  /// Path of Dart SDK
  String _sdkPath;

  String _version;

  factory DartSdk() {
    _self ??= DartSdk._internal(_detect());

    return _self;
  }

  DartSdk._internal(String sdkPath) {
    _sdkPath = sdkPath;
    Settings().verbose('Dart SDK Version  ${version}, path: ${_sdkPath}');
  }

  String get dartPath => p.join(_sdkPath, 'bin', 'dart');

  String get pubGetPath => p.join(_sdkPath, 'bin', 'pub');

  String get dart2NativePath => p.join(_sdkPath, 'bin', 'dart2native');

  Progress runDart2Native(
      Script script, String outputDir, String workingDirectory) {
    var runArgs = <String>[];
    runArgs.add(script.scriptname);
    runArgs.add('--output=${outputDir}/${script.basename}');

    return run(dart2NativePath, runArgs, workingDirectory);
  }

  Progress runPubGet(String workingDirectory, {Progress progress}) {
    return run(pubGetPath, ['get'], workingDirectory, progress: progress);
  }

  /// Runs a dart application.
  /// Throws a RunException on failure
  /// the project working dir.
  Progress run(String processPath, List<String> args, String workingDirectory,
      {Progress progress}) {
    Progress forEach;

    try {
      forEach = progress ?? Progress.forEach();

      var runnable = RunnableProcess.fromList(processPath, args,
          workingDirectory: workingDirectory);
      runnable.start();
      runnable.processUntilExit((line) => forEach.addToStdout(line),
          (line) => forEach.addToStderr(line));
    } finally {
      forEach.close();
    }
    return forEach;
  }

  static String _detect() {
    var executable = Platform.executable;
    final s = Platform.pathSeparator;

    if (!executable.contains(s)) {
      if (Platform.isLinux) {
        executable = Link('/proc/$pid/exe').resolveSymbolicLinksSync();
      }
    }

    final file = File(executable);
    if (!file.existsSync()) {
      throw dartSdkNotFound;
    }

    var parent = file.absolute.parent;
    parent = parent.parent; // TODO What if this does not exist?

    final sdkPath = parent.path;
    final dartApi = '$sdkPath${s}include${s}dart_api.h';
    if (!File(dartApi).existsSync()) {
      throw Exception('Cannot find Dart SDK!');
    }

    return sdkPath;
  }

  String get version {
    if (_version == null) {
      final res =
          waitFor<ProcessResult>(Process.run(dartPath, <String>['--version']));
      if (res.exitCode != 0) {
        throw Exception('Failed!');
      }

      var resultString = res.stderr as String;

      _version =
          resultString.substring('Dart VM version: '.length).split(' ').first;
    }

    return _version;
  }
}

final Exception dartSdkNotFound = Exception('Dart SDK not found!');
