/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:system_info2/system_info2.dart';

import '../../dcli.dart';
import '../../posix.dart' as posix;
import '../progress/progress_impl.dart';
import '../util/enum_helper.dart';
import '../util/runnable_process.dart';

/// The [DartSdk] provides access to a number of the dart sdk tools
/// as well as details on the active sdk instance.
class DartSdk {
  ///
  factory DartSdk() => _self ??= DartSdk._internal();

  DartSdk._internal();
  static DartSdk? _self;

  /// Path of Dart SDK
  String? _sdkPath;

  Version? _version;

  /// The path to the dart 'bin' directory.
  String get pathToSdk => _sdkPath ??= _detect();

  // Path the dart executable obtained by scanning the PATH
  late final String? _pathToDartExe = _determineDartPath();

  // Path the pub executable obtained by scanning the PATH
  late final String? _pathToPubExe = _determinePubPath();

  /// platform specific name of the 'dart' executable
  static String get dartExeName {
    if (core.Settings().isWindows) {
      if (isUsingDartFromFlutter) {
        return 'dart.bat';
      } else {
        return 'dart.exe';
      }
    } else {
      return 'dart';
    }
  }

  /// platform specific name of the 'pub' executable
  static String get pubExeName {
    if (core.Settings().isWindows) {
      return 'pub.bat';
    } else {
      return 'pub';
    }
  }

  /// platform specific name of the 'dart2native' executable
  static String get dart2NativeExeName {
    if (core.Settings().isWindows) {
      return 'dart2native.bat';
    } else {
      return 'dart2native';
    }
  }

  /// The path to the dart exe.
  /// Returns null if the the path cannot be foun.d
  String? get pathToDartExe => _pathToDartExe;

  /// file path to the 'pub' command.
  /// Returns null if the path cannot be found.
  String? get pathToPubExe => _pathToPubExe;

  // @Deprecated('Use pathToDartExe and dart compile')
  late final String? _pathToDartNativeExe = which(dart2NativeExeName).path;

  /// file path to the 'dart2native' command.
  String? get pathToDartToNativeExe => _pathToDartNativeExe;

  ///
  int get versionMajor => getVersion().major;

  ///
  int get versionMinor => getVersion().minor;

  /// From 2.10 onwards we use the dart compile option rather than dart2native.
  bool get useDartCommand =>
      getVersion().compareTo(Version.parse('2.10.0')) >= 0;

  // from 2.16 onward the doc command was migrated into dart.
  bool get useDartDocCommand =>
      getVersion().compareTo(Version.parse('2.16.0')) < 0;

  /// Returns the DartSdk's version
  Version getVersion() {
    if (_version == null) {
      final platform = Platform.version;
      final parts = platform.split(' ');

      if (parts.isEmpty) {
        throw core.DCliException('Failed to parse dart version: $platform');
      }

      final versionPart = parts[0];
      try {
        _version = Version.parse(versionPart);
      } on FormatException {
        throw core.DCliException('Failed to parse dart version: $versionPart');
      }

      verbose(() => 'Dart SDK Version  $_version');
    }

    return _version!;
  }

  /// Returns the DartSdk's version
  String get version => getVersion().toString();

  /// Run the 'dart compiler' command.
  /// [script] is the path to the dcli script we are compiling.
  /// [pathToExe] is the path (including the filename) to write the
  ///  compiled ex to .
  /// If [workingDirectory] is not passed then the current working directory is
  /// used. The [workingDirectory] should contain the pubspec.yaml that is used
  /// to compile the script.
  void runDartCompiler(
    DartScript script, {
    required String pathToExe,
    Progress? progress,
    String? workingDirectory,
  }) {
    final runArgs = <String>[];

    workingDirectory ??= script.pathToScriptDirectory;

    RunnableProcess process;
    if (useDartCommand) {
      /// use dart compile exe
      runArgs
        ..add('compile')
        ..add('exe')
        ..add(script.pathToScript)
        ..add('--output=$pathToExe');
      process = RunnableProcess.fromCommandArgs(
        dartExeName,
        runArgs,
        workingDirectory: script.pathToScriptDirectory,
      );
    } else {
      if (pathToDartToNativeExe == null) {
        throw DCliException(
          'Unable to compile as the dart2native executable '
          'not found on your path.',
        );
      }

      /// use old dart2native
      runArgs
        ..add(script.pathToScript)
        ..add('--output=$pathToExe');

      process = RunnableProcess.fromCommandArgs(
        pathToDartToNativeExe!,
        runArgs,
        workingDirectory: workingDirectory,
      );
    }

    process.start(extensionSearch: false, progress: progress! as ProgressImpl);
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
  Progress run({
    required List<String> args,
    String? workingDirectory,
    Progress? progress,
    bool detached = false,
    bool terminal = false,
    bool nothrow = false,
  }) {
    progress ??= Progress.print();

    if (pathToDartExe == null) {
      throw DCliException(
        "Unable to run 'dart' as the dart exe is not on your path",
      );
    }
    startFromArgs(
      pathToDartExe!,
      args,
      nothrow: nothrow,
      detached: detached,
      terminal: terminal,
      progress: progress,
      workingDirectory: workingDirectory,
      extensionSearch: false,
    );
    verbose(() => 'dart ${args.toList().join(' ')} finished.');

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
  Progress runPub({
    required List<String> args,
    String? workingDirectory,
    Progress? progress,
    bool nothrow = false,
  }) {
    progress ??= Progress.print();

    if (useDartCommand) {
      if (pathToDartExe == null) {
        throw DCliException(
          "Unable to run 'dart pub' as the dart exe is not on your path",
        );
      }
      startFromArgs(
        pathToDartExe!,
        ['pub', ...args],
        nothrow: nothrow,
        progress: progress,
        workingDirectory: workingDirectory,
        extensionSearch: false,
      );
    } else {
      if (pathToPubExe == null) {
        throw DCliException(
          "Unable to run 'pub' as the pub exe is not on your path",
        );
      }

      startFromArgs(
        pathToPubExe!,
        args,
        nothrow: nothrow,
        progress: progress,
        workingDirectory: workingDirectory,
        extensionSearch: false,
      );
    }
    verbose(() => 'dart pub ${args.toList().join(' ')} finished.');

    return progress;
  }

  /// Runs the 'dart doc' command with the given arguments.
  ///
  /// [pathToProject] is the location of the dart project.
  /// If [pathToProject] is not supplied the current working
  /// directory is used.
  ///
  /// [pathToDoc] is the path where the generated docs
  /// are to be saved. If not supplied then it is placed
  /// under a 'doc/api' directory in [pathToProject].
  /// [pathToDoc] may be an absolute or relative path.
  /// A relative path is assumed to be relative to [pathToProject]
  ///
  /// By default stdout and stderr are sent to the console.
  ///
  /// Pass in [progress] to control the output.
  /// If [nothrow] == true (defaults to false) then if the
  /// call to pub get fails an exit code will be returned in the
  /// [Progress] rather than throwing an exception.
  Progress runDartDoc({
    String? pathToProject,
    String? pathToDoc,
    List<String> args = const [],
    Progress? progress,
    bool nothrow = false,
  }) {
    pathToProject ??= pwd;
    pathToDoc ??= join(pathToProject, 'doc/api');

    progress ??= Progress.print();

    // if [pathToDoc] is absolute then it will be used
    // other wise it is treated as relative to pathToProject
    final docPath = join(pathToProject, pathToDoc);

    // ignore: parameter_assignments
    args = ['--output-dir', docPath, ...args];

    if (useDartDocCommand) {
      final w = which('dartdoc');
      if (w.notfound) {
        throw DCliException(
            "Unable to run 'dartdoc' as the exe is not on your path");
      }
      startFromArgs(
        w.path!,
        args,
        nothrow: nothrow,
        progress: progress,
        workingDirectory: pathToProject,
        extensionSearch: false,
      );
    } else {
      if (pathToDartExe == null) {
        throw DCliException(
          "Unable to run 'dart doc' as the dart exe is not on your path",
        );
      }
      startFromArgs(
        pathToDartExe!,
        ['doc', ...args, '.'],
        nothrow: nothrow,
        progress: progress,
        workingDirectory: pathToProject,
        extensionSearch: false,
      );
    }
    verbose(() => 'dart doc ${args.toList().join(' ')} finished.');

    return progress;
  }

  /// Returns true if you need to run pub get.
  /// If there is no pubspec.yaml in the workingDirectory
  /// then an [PubspecNotFoundException] will be thrown.
  /// Running pub get is required if any of the following
  /// are older (or don't exist) than your pubspec.yaml file:
  ///  pubspec.lock
  /// .dart_tool/package_config.json
  ///
  bool isPubGetRequired(String workingDirectory) {
    if (!exists(join(workingDirectory, 'pubspec.yaml'))) {
      throw PubspecNotFoundException(workingDirectory);
    }

    final modified = stat(join(workingDirectory, 'pubspec.yaml')).modified;

    final lock = join(workingDirectory, 'pubspec.lock');
    if (!exists(lock) || stat(lock).modified.isBefore(modified)) {
      return true;
    }

    final config = join(workingDirectory, '.dart_tool', 'package_config.json');
    if (!exists(config) || stat(config).modified.isBefore(modified)) {
      return true;
    }

    return false;
  }

  /// runs 'dart pub get'
  void runPubGet(
    String? workingDirectory, {
    Progress? progress,
    bool compileExecutables = false,
  }) {
    runPub(
      args: ['get', if (!compileExecutables) '--no-precompile'],
      workingDirectory: workingDirectory,
      progress: progress,
    );
  }

  /// runs 'dart pub upgrade'
  void runPubUpgrade(
    String? workingDirectory, {
    Progress? progress,
    bool compileExecutables = false,
  }) {
    runPub(
      args: ['upgrade', if (!compileExecutables) '--no-precompile'],
      workingDirectory: workingDirectory,
      progress: progress,
    );
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

  /// Installs the latest version of DartSdk from the official google archives
  /// This is simply the process of downloading and extracting the
  /// sdk to the [defaultDartSdkPath].
  ///
  /// If [askUser] is true (the default) the user is asked to confirm the
  /// install path and can modifiy it if desired.
  ///
  /// returns the directory where the dartSdk was installed.
  Future<String> installFromArchive(String defaultDartSdkPath,
      {bool askUser = true}) async {
    // verbose(() => 'Architecture: ${SysInfo.kernelArchitecture}');
    final zipRelease = await _fetchDartSdk();

    var installDir = defaultDartSdkPath;

    if (askUser) {
      installDir = _askForDartSdkInstallDir(defaultDartSdkPath);
    }

    Shell.current.withPrivileges(() {
      if (!exists(installDir)) {
        createDir(installDir, recursive: true);
      } else {
        print(
          'The install directory $installDir already exists. '
          'If you proceed all files under $installDir will be deleted.',
        );
        if (confirm('Proceed to delete $installDir')) {
          /// I've added this incase we have a failed install and
          /// need to do a restart.
          ///
          deleteDir(installDir);
        } else {
          throw InstallException(
              'Install Directory $installDir already exists.');
        }
      }
    });

    // Read the Zip file from disk.
    _extractDartSdk(zipRelease, installDir);
    delete(zipRelease);

    /// the archive creates a root of 'dart-sdk' we need to move
    /// all of the files directly under the [installDir] (/usr/bin/dart).
    print('Preparing dart sdk');
    moveTree(join(installDir, 'dart-sdk'), installDir, includeHidden: true);
    deleteDir(join(installDir, 'dart-sdk'));

    if (core.Settings().isLinux || core.Settings().isMacOS) {
      /// make execs executable.
      find('*', workingDirectory: join(installDir, 'bin'), recursive: false)
          .forEach((file) => posix.chmod(file, permission: '500'));
    }

    // The normal dart detection process won't work here
    // as dart is not on the path so for the moment we force it
    // to the path we just downloaded it to.
    setPathToDartSdk(installDir);

    return installDir;
  }

  /// Fetchs the list of available dart versions from
  // List<String> fetchVersions() {}
  Future<String> _fetchDartSdk() async {
    final architechture = resolveArchitecture();
    final platform = Platform.operatingSystem;

    final zipRelease = createTempFilename(suffix: 'release.zip');

    // the sdk's can be found here:
    /// https://dart.dev/tools/sdk/archive

    final term = Terminal();
    if (term.isAnsi) {
      term.showCursor(show: false);
    }

    await fetch(
      url:
          'https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-$platform-$architechture-release.zip',
      saveToPath: zipRelease,
      fetchProgress: (p) => echo('.'),
    );

    if (term.isAnsi) {
      term.showCursor(show: true);
    }
    print('');
    return zipRelease;
  }

  /// Converts the kernel architecture into one of the architecture names use
  /// by:
  /// https://dart.dev/tools/sdk/archive
  String resolveArchitecture() {
    if (Platform.isMacOS) {
      return 'x64';
    } else if (Platform.isWindows) {
      if (SysInfo.kernelBitness == 32) {
        return 'ia32';
      } else {
        return 'x64';
      }
    } else // linux
    {
      final architecture = SysInfo.kernelArchitecture;
      if (architecture == ProcessorArchitecture.arm64) {
        return 'ARMv8';
      } else if (architecture == ProcessorArchitecture.arm) {
        return 'ARMv7';
      } else if (architecture == ProcessorArchitecture.ia64) {
        return 'X64';
      } else if (architecture == ProcessorArchitecture.mips) {
        throw const OSError('Mips is not a supported architecture.');
      } else if (architecture == ProcessorArchitecture.x86) {
        return 'ia32';
      } else if (architecture == ProcessorArchitecture.x86_64) {
        return 'x64';
      }
      throw OSError(
          '${SysInfo.rawKernelArchitecture} is not a supported architecture.');
    }
  }

  String _askForDartSdkInstallDir(String dartToolDir) {
    var confirmed = false;
    var finaldartToolDir = dartToolDir;

    /// ask for and confirm the install directory.
    while (!confirmed) {
      final entered = ask(
        'Install dart-sdk to (Enter for default '
        '[${truepath(finaldartToolDir)}]): ',
      );
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
  // ignore: unused_element
  Future<void> _showProgress(FetchProgress progress) async {
    final term = Terminal();
    final percentage = Format().percentage(progress.progress, 1);
    if (term.isAnsi) {
      term
        ..clearLine()
        ..startOfLine();
      echo(
        '${EnumHelper().getName(progress.status).padRight(15)}${Format().bytesAsReadable(progress.downloaded)}/${Format().bytesAsReadable(progress.length)} $percentage',
      );
    } else {
      if (_progressSuppressor % 1000 == 0 ||
          progress.status == FetchStatus.complete) {
        print(
          '${EnumHelper().getName(progress.status).padRight(15)}${Format().bytesAsReadable(progress.downloaded)}/${Format().bytesAsReadable(progress.length)} $percentage',
        );
      }
      _progressSuppressor++;
      if (_progressSuppressor > 1000) {
        _progressSuppressor = 0;
      }
    }
  }

  /// Run dart pub global activate on the given [package].
  @Deprecated('Use PubCache().globalActivate')
  void globalActivate(String package) {
    runPub(
      args: ['global', 'activate', package],
      progress: Progress.printStdErr(),
    );
  }

  /// Run dart pub global activate for a package located in [path]
  /// relative to the current directory.
  @Deprecated('Use PubCache().globalActivateFromSource')
  void globalActivateFromPath(String path) =>
      PubCache().globalActivateFromSource(path);

  /// Run dart pub global deactivate on the given [package].
  @Deprecated('Use PubCache().globalDeactivate')
  void globalDeactivate(String package) => PubCache().globalDeactivate(package);

  /// returns true if the given package has been globally activated
  @Deprecated('Use PubCache().isGloballyActivated')
  bool isPackageGloballyActivated(String package) =>
      PubCache().isGloballyActivated(package);

  /// Run dart pub global activate for a package located in [path]
  /// relative to the current directory.
  @Deprecated('Use PubCache().isGloballyActivatedFromSource')
  void isPackageGlobalActivateFromPath(String path) =>
      PubCache().isGloballyActivatedFromSource(path);

  String? _determineDartPath() {
    var path = which('dart').path;

    if (path == null) {
      /// lets try some likely locations
      path = '/usr/lib/dart/bin/dart';
      if (exists(path)) {
        return path;
      }

      path = '/usr/bin/dart';
      if (exists(path)) {
        return path;
      }
    }

    if (Platform.isWindows) {
      // flutter ships with both a dart and a dart.bat
      // we must target the dart.bat as the dart version
      // is actually an unusable (on windows) bash shell.
      final dartbat = join(dirname(path), 'dart.bat');
      if (exists(dartbat)) {
        path = dartbat;
      }
    }

    return path;
  }

  static bool get isUsingDartFromFlutter {
    final path = which('dart').path;

    if (path == null) {
      return false;
    }
    return dirname(dirname(path)).endsWith('flutter');
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

    if (Platform.isWindows) {
      final dartbat = join(dirname(pubPath), 'pub.bat');
      if (exists(dartbat)) {
        pubPath = dartbat;
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
@visibleForTesting
void setPathToDartSdk(String dartSdkPath) {
  DartSdk()._sdkPath = dartSdkPath;
}

/// Throw if pubspec.yaml was not found.
class PubspecNotFoundException extends DCliException {
  /// Throw if pubspec.yaml was not found in [workingDirectory]
  PubspecNotFoundException(String workingDirectory)
      : super('pubspec.yaml not found in $workingDirectory');
}
