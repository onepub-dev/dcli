import 'dart:cli';
import 'dart:io';
import '../../dshell.dart';
import '../util/progress.dart';
import '../util/runnable_process.dart';
import 'package:path/path.dart' as p;

/// The [DartSdk] provides access to a number of the dart sdk tools
/// as well as details on the active sdk instance.
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

  /// The path to the dart 'bin' directory.
  String get sdkPath {
    _sdkPath ??= _detect();
    return _sdkPath;
  }

  static String get dartExeName
  {
    if (Platform.isWindows)
    {
      return 'dart.exe';
    }
    else
    {
      return 'dart';
    }
  }

  static String get pubExeName
  {
     if (Platform.isWindows)
    {
      return 'pub.bat';
    }
    else
    {
      return 'pub';
    }

  }


  static String get dart2NativeExeName
  {
     if (Platform.isWindows)
    {
      return 'dart2native.bat';
    }
    else
    {
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

  String get pubGetPath => p.join(sdkPath, 'bin', pubExeName);

  String get dart2NativePath => p.join(sdkPath, 'bin', dart2NativeExeName);

  void runDart2Native(
      String runtimeScriptPath, String outputDir, String runtimePath,
      {Progress progress}) {
    var runArgs = <String>[];
    runArgs.add(runtimeScriptPath);
    runArgs.add('--packages=${join(runtimePath, ".packages")}');
    runArgs.add(
        '--output=${join(outputDir, basenameWithoutExtension(runtimeScriptPath))}');

    var process = RunnableProcess.fromCommandArgs(
      dart2NativePath,
      runArgs,
    );

    process.start();

    process.processUntilExit(progress, nothrow: false);
  }

  void runPubGet(String workingDirectory,
      {Progress progress, bool compileExecutables}) {
    var process = RunnableProcess.fromCommandArgs(
        pubGetPath, ['get', '--no-precompile'],
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

final Exception dartSdkNotFound = Exception('Dart SDK not found!');
