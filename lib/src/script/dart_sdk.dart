import 'dart:cli';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../dshell.dart';
import '../util/progress.dart';
import '../util/runnable_process.dart';

/// The [DartSdk] provides access to a number of the dart sdk tools
/// as well as details on the active sdk instance.
class DartSdk {
  static DartSdk _self;

  /// Path of Dart SDK
  String _sdkPath;

  // Path the dart executable obtained by scanning the PATH
  String _exePath;

  String _version;

  ///
  factory DartSdk() {
    _self ??= DartSdk._internal();

    return _self;
  }

  DartSdk._internal() {
    if (Settings().isVerbose) {
      // expensive operation so only peform if required.
      Settings().verbose('Dart SDK Version  $version, path: $_sdkPath');
    }
  }

  /// The path to the dart 'bin' directory.
  String get sdkPath {
    _sdkPath ??= _detect();
    return _sdkPath;
  }

  /// platform specific name of the 'dart' executable
  static String get dartExeName {
    if (Platform.isWindows) {
      return 'dart.exe';
    } else {
      return 'dart';
    }
  }

  /// platform specific name of the 'pub' executable
  static String get pubExeName {
    if (Platform.isWindows) {
      return 'pub.bat';
    } else {
      return 'pub';
    }
  }

  /// platform specific name of the 'dart2native' executable
  static String get dart2NativeExeName {
    if (Platform.isWindows) {
      return 'dart2native.bat';
    } else {
      return 'dart2native';
    }
  }

  /// The path to the dart exe.
  String get dartExePath {
    if (_exePath == null) {
      // this is an expesive operation so only do it if required.
      var path = which(dartExeName, first: true).firstLine;
      assert(path != null);
      _exePath = path;
    }
    return _exePath;
  }

  /// file path to the 'pub' command.
  String get pubPath => p.join(sdkPath, 'bin', pubExeName);

  /// file path to the 'dart2native' command.
  String get dart2NativePath => p.join(sdkPath, 'bin', dart2NativeExeName);

  /// run the 'dart2native' command.
  /// [runtimeScriptPath] is the path of the dshell script we are compiling.
  /// [outputPath] is the path to write the compiled ex to .
  /// [runtimePath] is the path to execute 'dart2native' in.
  void runDart2Native(
      String runtimeScriptPath, String outputPath, String runtimePath,
      {Progress progress}) {
    var runArgs = <String>[];
    runArgs.add(runtimeScriptPath);
    runArgs.add('--packages=${join(runtimePath, ".packages")}');
    runArgs.add(
        '--output=${join(outputPath, basenameWithoutExtension(runtimeScriptPath))}');

    var process = RunnableProcess.fromCommandArgs(
      dart2NativePath,
      runArgs,
    );

    process.start();

    process.processUntilExit(progress, nothrow: false);
  }

  /// runs 'pub get'
  void runPubGet(String workingDirectory,
      {Progress progress, bool compileExecutables}) {
    var process = RunnableProcess.fromCommandArgs(
        pubPath, ['get', '--no-precompile'],
        workingDirectory: workingDirectory);

    process.start();

    process.processUntilExit(progress, nothrow: false);
    Settings().verbose('pub get finished');
  }

  static String _detect() {
    var path = which(pubExeName).firstLine;

    if (path != null) {
      return dirname(dirname(path));
    } else {
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
  }

  /// returns the version of date.
  String get version {
    if (_version == null) {
      final res = waitFor<ProcessResult>(
          Process.run(dartExePath, <String>['--version']));
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

/// Exception throw if we can't find the dart sdk.
final Exception dartSdkNotFound = Exception('Dart SDK not found!');
