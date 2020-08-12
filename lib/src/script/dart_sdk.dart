import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dshell/src/script/virtual_project.dart';
import 'package:path/path.dart' as p;
import 'package:system_info/system_info.dart';

import '../../dshell.dart';
import '../util/enum_helper.dart';
import '../util/file_system.dart';
import '../util/progress.dart';
import '../util/runnable_process.dart';
import '../util/terminal.dart';
import 'commands/install.dart';

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

  DartSdk._internal();

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
  /// [runtimeScriptPath] is the path to the dshell script we are compiling.
  /// [outputPath] is the path to write the compiled ex to .
  /// [projectRootPath] is the path to the projects root directory.
  void runDart2Native(VirtualProject project, String runtimeScriptPath,
      String outputPath, String projectRootPath,
      {Progress progress}) {
    var runArgs = <String>[];
    runArgs.add(runtimeScriptPath);
    if (project.pubspecLocation != PubspecLocation.traditional &&
        project.pubspecLocation != PubspecLocation.local) {
      runArgs.add(
          '--packages=${join(dirname(project.projectPubspecPath), '.dart_tool', 'package_config.json')}');
    }
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

  /// returns the version of dart.
  String get version {
    if (_version == null) {
      var output = '${dartExePath} --version'.firstLine;

      /// extract the version out of the dumped line.
      var regx = RegExp(r'[0-9]*\.[0-9]*\.[0-9]*');
      var parsed = regx.firstMatch(output);
      if (parsed != null) {
        _version = parsed.group(0);
      }

      Settings().verbose('Dart SDK Version  $_version, path: $dartExePath');
    }

    return _version;
  }

  /// Installs the latest version of DartSdk from the official google archives
  /// This is simply the process of downloading and extracting the
  /// sdk to the [defaultDartSdkPath].
  ///
  /// If [askUser] is true (the default) the user is asked to confirm the
  /// install path and can modifiy it if desired.
  ///
  /// returns the directory where the dartSdk was installed.
  String installFromArchive(String defaultDartSdkPath, {bool askUser = true}) {
    Settings().verbose('Architecture: ${SysInfo.kernelArchitecture}');
    var zipRelease = _fetchDartSdk();

    var installDir = defaultDartSdkPath;

    if (askUser) installDir = _askForDartSdkInstallDir(defaultDartSdkPath);

    if (!exists(installDir)) {
      createDir(installDir, recursive: true);
    } else {
      print(
          'The install directory $installDir already exists. If you proceed all files under $installDir will be deleted.');
      if (confirm(prompt: 'Proceed to delete $installDir')) {
        /// I've added this incase we have a failed install and need to do a restart.
        ///
        deleteDir(installDir, recursive: true);
      } else {
        throw InstallException('Install Directory $installDir already exists.');
      }
    }

    // Read the Zip file from disk.
    _extractDartSdk(zipRelease, installDir);
    delete(zipRelease);

    /// the archive creates a root of 'dart-sdk' we need to move
    /// all of the files directly under the [installDir] (/usr/bin/dart).
    print('Preparing dart sdk');
    moveTree(join(installDir, 'dart-sdk'), installDir, includeHidden: true);
    deleteDir(join(installDir, 'dart-sdk'));

    if (Platform.isLinux || Platform.isMacOS) {
      /// make execs executable.
      find('*', root: join(installDir, 'bin'), recursive: false)
          .forEach((file) => 'chmod +x, $file'.run);
    }

    // The normal dart detection process won't work here
    // as dart is not on the path so for the moment we force it
    // to the path we just downloaded it to.
    setDartSdkPath(installDir);

    return installDir;
  }

  String _fetchDartSdk() {
    var bitness = SysInfo.kernelBitness;
    var architechture = 'x64';
    if (bitness == 32) {
      architechture = 'ia32';
    }
    var platform = Platform.operatingSystem;

    var zipRelease = FileSync.tempFile(suffix: 'release.zip');

    // the sdk's can be found here:
    /// https://dart.dev/tools/sdk/archive

    var term = Terminal();
    if (term.isAnsi) term.showCursor(show: false);

    fetch(
        url:
            'https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-$platform-$architechture-release.zip',
        saveToPath: zipRelease,
        onProgress: _showProgress);

    if (term.isAnsi) term.showCursor(show: true);
    print('');
    return zipRelease;
  }

  String _askForDartSdkInstallDir(String dartToolDir) {
    var confirmed = false;

    /// ask for and confirm the install directory.
    while (!confirmed) {
      var entered = ask(
          prompt:
              'Install dart-sdk to (Enter for default [${truepath(dartToolDir)}]): ');
      if (entered.isNotEmpty) {
        dartToolDir = entered;
      }

      confirmed = confirm(prompt: 'Is $dartToolDir correct:');
    }

    return dartToolDir;
  }

  void _extractDartSdk(String zipRelease, String dartToolDir) {
    print('Extracting dart sdk..');
    // Read the Zip file from disk.
    final bytes = File(zipRelease).readAsBytesSync();

    // Decode the Zip file
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      var path = join(dartToolDir, filename);
      if (file.isFile) {
        final data = file.content as List<int>;
        File(path)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        echo('.');
      } else {
        createDir(path, recursive: true);
      }
    }
    print('');
  }

  int _progressSuppressor = 0;
  void _showProgress(FetchProgress progress) {
    var term = Terminal();
    var percentage = Format().percentage(progress.progress, 1);
    if (term.isAnsi) {
      term.clearLine(mode: TerminalClearMode.all);
      term.startOfLine();
      echo(
          '${EnumHelper.getName(progress.status).padRight(15)}${humanNumber(progress.downloaded)}/${humanNumber(progress.length)} $percentage');
    } else {
      if (_progressSuppressor % 1000 == 0 ||
          progress.status == FetchStatus.complete) {
        print(
            '${EnumHelper.getName(progress.status).padRight(15)}${humanNumber(progress.downloaded)}/${humanNumber(progress.length)} $percentage');
      }
      _progressSuppressor++;
      if (_progressSuppressor > 1000) _progressSuppressor = 0;
    }
  }
}

/// Exception throw if we can't find the dart sdk.
final Exception dartSdkNotFound = Exception('Dart SDK not found!');

/// This method is ONLY for use by the installer so that we can
/// set the path during the install when it won't be detectable
/// as its not on the system path.
void setDartSdkPath(String dartSdkPath) {
  DartSdk()._sdkPath = dartSdkPath;
}
