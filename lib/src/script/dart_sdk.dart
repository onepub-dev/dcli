import 'dart:cli';
import 'dart:io';
import '../../dshell.dart';
import 'script.dart';
import '../util/progress.dart';
import '../util/runnable_process.dart';
import 'package:path/path.dart' as p;

/// The [DartSdk] implementation where the Dart sdk directory is detected.
class DartSdk {
  static DartSdk _self;

  /// Path of Dart SDK
  String _sdkPath;

  // Path the dart executable obtained by scanning the PATH
  String _exePath;

  String _version;

  factory DartSdk() {
    _self ??= DartSdk._internal();

    return _self;
  }

  DartSdk._internal() {
    if (Settings().isVerbose) {
      // expensive operation so only peform if required.
      Settings().verbose('Dart SDK Version  ${version}, path: ${_sdkPath}');
    }
  }

  String get sdkPath {
    _sdkPath ??= _detect();
    return _sdkPath;
  }

  String get exePath {
    if (_exePath == null) {
      // this is an expesive operation so only do it if required.
      var path = which('dart', first: true).firstLine;
      assert(path != null);
      _exePath = path;
    }
    return _exePath;
  }

  String get dartPath => p.join(sdkPath, 'bin', 'dart');

  String get pubGetPath => p.join(sdkPath, 'bin', 'pub');

  String get dart2NativePath => p.join(sdkPath, 'bin', 'dart2native');

  Progress runDart2Native(
      Script script, String outputDir, String workingDirectory,
      {Progress progress}) {
    var runArgs = <String>[];
    runArgs.add(script.path);
    runArgs.add('--output=${join(outputDir, script.basename)}');

    return run(dart2NativePath, runArgs, workingDirectory, progress: progress);
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

      Settings().verbose(
          "running $processPath workingDir: $workingDirectory args: ${args.join(',')}");
      var runnable = RunnableProcess.fromList(processPath, args,
          workingDirectory: workingDirectory);
      runnable.start(runInShell: false);
      runnable.processUntilExit((line) => forEach.addToStdout(line),
          (line) => forEach.addToStderr(line));
    } finally {
      forEach.close();
    }
    return forEach;
  }

  static String _detect() {
    var executable = Platform.resolvedExecutable;

    final file = File(executable);
    if (!file.existsSync()) {
      throw dartSdkNotFound;
    }

    var parent = file.absolute.parent;
    parent = parent.parent;

    final sdkPath = parent.path;
    final dartApi = "${join(sdkPath, 'include', 'dart_api.h')}";
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
