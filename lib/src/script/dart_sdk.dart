import 'dart:io';

import 'package:archive/archive.dart';
import 'package:pub_semver/pub_semver.dart';
import '../../dcli.dart';
import '../util/enum_helper.dart';
import '../util/progress.dart';
import '../util/runnable_process.dart';
import '../util/terminal.dart';
import 'commands/install.dart';

/// The [DartSdk] provides access to a number of the dart sdk tools
/// as well as details on the active sdk instance.
class DartSdk {
  ///
  factory DartSdk() => _self ??= DartSdk._internal();

  DartSdk._internal();
  static DartSdk? _self;

  /// Path of Dart SDK
  String? _sdkPath;

  String? _version;

  /// The path to the dart 'bin' directory.
  String get pathToSdk => _sdkPath ??= _detect();

  // Path the dart executable obtained by scanning the PATH
  late final String? _pathToDartExe = _determineDartPath();

  // Path the pub executable obtained by scanning the PATH
  late final String? _pathToPubExe = _determinePubPath();

  /// platform specific name of the 'dart' executable
  static String get dartExeName {
    if (Settings().isWindows) {
      return 'dart.exe';
    } else {
      return 'dart';
    }
  }

  /// platform specific name of the 'pub' executable
  static String get pubExeName {
    if (Settings().isWindows) {
      return 'pub.bat';
    } else {
      return 'pub';
    }
  }

  /// platform specific name of the 'dart2native' executable
  static String get dart2NativeExeName {
    if (Settings().isWindows) {
      return 'dart2native.bat';
    } else {
      return 'dart2native';
    }
  }

  /// The path to the dart exe.
  String? get pathToDartExe => _pathToDartExe;

  /// file path to the 'pub' command.
  String? get pathToPubExe => _pathToPubExe;

  // @Deprecated('Use pathToDartExe and dart compile')
  late final String? _pathToDartNativeExe = which(dart2NativeExeName).path;

  /// file path to the 'dart2native' command.
  String? get pathToDartToNativeExe => _pathToDartNativeExe;

  ///
  int get versionMajor {
    final parts = version!.split('.');

    return int.tryParse(parts[0]) ?? 2;
  }

  ///
  int get versionMinor {
    final parts = version!.split('.');

    return int.tryParse(parts[1]) ?? 9;
  }

  /// From 2.10 onwards we use the dart compile option rather than dart2native.
  bool get useDartCommand {
    final platform = Platform.version;
    final parts = platform.split(' ');
    final dartVersion = Version.parse(parts[0]);
    return dartVersion.compareTo(Version.parse('2.10.0')) >= 0;
  }

  /// Run the 'dart compiler' command.
  /// [script] is the path to the dcli script we are compiling.
  /// [pathToExe] is the path (including the filename) to write the
  ///  compiled ex to .
  void runDartCompiler(DartScript script,
      {required String pathToExe, Progress? progress}) {
    final runArgs = <String>[];

    RunnableProcess process;
    if (useDartCommand) {
      /// use dart compile exe
      runArgs
        ..add('compile')
        ..add('exe')
        ..add(script.pathToScript)
        ..add('--output=$pathToExe');
      process = RunnableProcess.fromCommandArgs(dartExeName, runArgs,
          workingDirectory: script.pathToScriptDirectory);
    } else {
      if (pathToDartToNativeExe == null) {
        throw DCliException('Unable to compile as the dart2native executable '
            'not found on your path.');
      }

      /// use old dart2native
      runArgs..add(script.pathToScript)..add('--output=$pathToExe');

      process = RunnableProcess.fromCommandArgs(pathToDartToNativeExe!, runArgs,
          workingDirectory: script.pathToScriptDirectory);
    }

    process
      ..start()
      ..processUntilExit(progress, nothrow: false);
  }

  /// returns the relative path to the packges configuration file.
  /// For versions of dart prior to 2.10 this returns '.packages'
  /// For versions of dart from 2.10 it returns .dart_tools/package_config.json
  String get pathToPackageConfig {
    if (DartSdk().versionMajor >= 2 && DartSdk().versionMinor >= 10) {
      return join('.dart_tool', 'package_config.json');
    } else {
      return '.packages';
    }
  }

  /// Run the dart exe with arguments.
  Progress run(
      {required List<String> args,
      String? workingDirectory,
      Progress? progress,
      bool nothrow = false}) {
    progress ??= Progress.print();

    if (pathToDartExe == null) {
      throw DCliException(
          "Unable to run 'dart' as the dart exe is not on your path");
    }
    startFromArgs(pathToDartExe!, args,
        nothrow: nothrow,
        progress: progress,
        workingDirectory: workingDirectory);
    Settings().verbose('dart ${args.toList().join(' ')} finished.');

    return progress;
  }

  /// Runs the 'dart pub' command with the given arguments.
  ///
  /// By default stdout and stderr are sent to the console.
  ///
  /// Pass in [progress] to control the output.
  /// If [nothrow] == true (defaults to false) then if the
  /// call to pub get fails an exit code will be returned in the
  /// [Progress] rather than throwing an exception.
  Progress runPub(
      {required List<String> args,
      String? workingDirectory,
      Progress? progress,
      bool nothrow = false}) {
    progress ??= Progress.print();

    if (useDartCommand) {
      if (pathToDartExe == null) {
        throw DCliException(
            "Unable to run 'dart pub' as the dart exe is not on your path");
      }
      startFromArgs(pathToDartExe!, ['pub', ...args],
          nothrow: nothrow,
          progress: progress,
          workingDirectory: workingDirectory);
    } else {
      if (pathToPubExe == null) {
        throw DCliException(
            "Unable to run 'pub' as the pub exe is not on your path");
      }

      startFromArgs(pathToPubExe!, args,
          nothrow: nothrow,
          progress: progress,
          workingDirectory: workingDirectory);
    }
    Settings().verbose('dart pub ${args.toList().join(' ')} finished.');

    return progress;
  }

  /// runs 'pub get'
  void runPubGet(
    String? workingDirectory, {
    Progress? progress,
    bool? compileExecutables,
  }) {
    runPub(
        args: ['get', '--no-precompile'],
        workingDirectory: workingDirectory,
        progress: progress);
  }

  /// Attempts to detect the location of the dart sdk.
  static String _detect() {
    final whichExe = which(dartExeName);

    if (whichExe.found) {
      return dirname(dirname(File(whichExe.path!).resolveSymbolicLinksSync()));
    } else {
      final executable = Platform.resolvedExecutable;

      final file = File(executable);
      if (!file.existsSync()) {
        throw dartSdkNotFound;
      }

      var parent = file.absolute.parent;
      parent = parent.parent;

      final sdkPath = parent.path;
      final dartApi = join(sdkPath, 'include', 'dart_api.h');
      if (!File(dartApi).existsSync()) {
        throw Exception('Cannot find Dart SDK!');
      }

      return sdkPath;
    }
  }

  /// returns the version of dart.
  String? get version {
    if (_version == null) {
      /// extract the version out of the dumped line.
      final regx = RegExp(r'[0-9]*\.[0-9]*\.[0-9]*');
      final parsed = regx.firstMatch(Platform.version);
      if (parsed != null) {
        _version = parsed.group(0);
      }

      Settings().verbose('Dart SDK Version  $_version');
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
    // Settings().verbose('Architecture: ${SysInfo.kernelArchitecture}');
    final zipRelease = _fetchDartSdk();

    var installDir = defaultDartSdkPath;

    if (askUser) {
      installDir = _askForDartSdkInstallDir(defaultDartSdkPath);
    }

    if (!exists(installDir)) {
      createDir(installDir, recursive: true);
    } else {
      print('The install directory $installDir already exists. '
          'If you proceed all files under $installDir will be deleted.');
      if (confirm('Proceed to delete $installDir')) {
        /// I've added this incase we have a failed install and
        /// need to do a restart.
        ///
        deleteDir(installDir);
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
      find('*', workingDirectory: join(installDir, 'bin'), recursive: false)
          .forEach((file) => 'chmod +x, $file'.run);
    }

    // The normal dart detection process won't work here
    // as dart is not on the path so for the moment we force it
    // to the path we just downloaded it to.
    setPathToDartSdk(installDir);

    return installDir;
  }

  /// Fetchs the list of available dart versions from
  // List<String> fetchVersions() {}

  String _fetchDartSdk() {
    // final bitness = SysInfo.kernelBitness;
    const architechture = 'x64';
    // if (bitness == 32) {
    //   architechture = 'ia32';
    // }
    final platform = Platform.operatingSystem;

    final zipRelease = createTempFilename(suffix: 'release.zip');

    // the sdk's can be found here:
    /// https://dart.dev/tools/sdk/archive

    final term = Terminal();
    if (term.isAnsi) {
      term.showCursor(show: false);
    }

    fetch(
        url:
            'https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-$platform-$architechture-release.zip',
        saveToPath: zipRelease,
        fetchProgress: _showProgress);

    if (term.isAnsi) {
      term.showCursor(show: true);
    }
    print('');
    return zipRelease;
  }

  String _askForDartSdkInstallDir(String dartToolDir) {
    var confirmed = false;
    var finaldartToolDir = dartToolDir;

    /// ask for and confirm the install directory.
    while (!confirmed) {
      final entered = ask('Install dart-sdk to (Enter for default '
          '[${truepath(finaldartToolDir)}]): ');
      if (entered.isNotEmpty) {
        finaldartToolDir = entered;
      }

      confirmed = confirm('Is $finaldartToolDir correct:');
    }

    return finaldartToolDir;
  }

  void _extractDartSdk(String zipRelease, String dartToolDir) {
    print('Extracting dart sdk..');
    // Read the Zip file from disk.
    final bytes = File(zipRelease).readAsBytesSync();

    // Decode the Zip file
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      final path = join(dartToolDir, filename);
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
  Future<void> _showProgress(FetchProgress progress) async {
    final term = Terminal();
    final percentage = Format.percentage(progress.progress, 1);
    if (term.isAnsi) {
      term
        ..clearLine()
        ..startOfLine();
      echo(
          '${EnumHelper.getName(progress.status).padRight(15)}${Format.bytesAsReadable(progress.downloaded)}/${Format.bytesAsReadable(progress.length)} $percentage');
    } else {
      if (_progressSuppressor % 1000 == 0 ||
          progress.status == FetchStatus.complete) {
        print(
            '${EnumHelper.getName(progress.status).padRight(15)}${Format.bytesAsReadable(progress.downloaded)}/${Format.bytesAsReadable(progress.length)} $percentage');
      }
      _progressSuppressor++;
      if (_progressSuppressor > 1000) {
        _progressSuppressor = 0;
      }
    }
  }

  /// Run dart pub global activate on the given [package].
  void globalActivate(String package) {
    runPub(
        args: ['global', 'activate', 'dcli'], progress: Progress.printStdErr());
  }

  /// Run dart pub global activate for a packae located in [path]
  /// relative to the current directory.
  void globalActivateFromPath(String path) {
    runPub(
        args: ['global', 'activate', '--source', 'path', path],
        progress: Progress.printStdErr());
  }

  String? _determineDartPath() {
    var _path = which(dartExeName).path;

    if (_path == null) {
      /// lets try some likely locations
      _path = '/usr/lib/dart/bin/dart';
      if (exists(_path)) {
        return _path;
      }

      _path = '/usr/bin/dart';
      if (exists(_path)) {
        return _path;
      }
    }

    return _path;
  }

  // The normal dart detection process may not work here
  // as dart may not be on the path
  // So lets go find it
  // CONSIDER a way of identifying where dart has been installed to.
  String? _determinePubPath() {
    var pubPath = which(pubExeName).path;

    if (pubPath == null) {
      /// lets try some likely locations

      pubPath = '/usr/lib/dart/bin/pub';
      if (exists(pubPath)) {
        return pubPath;
      }

      pubPath = '/usr/bin/pub';
      if (exists(pubPath)) {
        return pubPath;
      }
    }

    /// radical - search everywhere
    /// The performance of find essentially precludes this.
    // print('Searching for pub');
    // // pubPath =
    // find('pub', workingDirectory: '/', progress: Progress.print());

    return pubPath;
  }
}

/// Exception throw if we can't find the dart sdk.
final Exception dartSdkNotFound = Exception('Dart SDK not found!');

/// This method is ONLY for use by the installer so that we can
/// set the path during the install when it won't be detectable
/// as its not on the system path.
void setPathToDartSdk(String dartSdkPath) {
  DartSdk()._sdkPath = dartSdkPath;
}
