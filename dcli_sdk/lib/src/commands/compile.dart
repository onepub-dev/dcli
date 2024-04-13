import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart';
import 'package:pubspec_manager/pubspec_manager.dart';

import '../script/flags.dart';
import '../util/completion.dart';
import '../util/exceptions.dart';
import '../util/exit.dart';
import 'commands.dart';
import 'run.dart';

/// implementation for the compile command.
class CompileCommand extends Command {
  ///
  CompileCommand() : super(_commandName);
  static const String _commandName = 'compile';

  final _compileFlags = [
    NoWarmupFlag(),
    InstallFlag(),
    OverWriteFlag(),
    PackageFlag(),
    //WatchFlag()
  ];

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  @override
  Future<int> run(List<Flag> selectedFlags, List<String> subarguments) async {
    const exitCode = 0;

    var scriptIndex = 0;

    // check for any flags
    for (var i = 0; i < subarguments.length; i++) {
      final subargument = subarguments[i];

      if (Flags.isFlag(subargument)) {
        scriptIndex++;
        final flag = flagSet.findFlag(subargument, _compileFlags);

        if (flag != null) {
          if (flagSet.isSet(flag)) {
            throw DuplicateOptionsException(subargument);
          }
          flagSet.set(flag);
          verbose(() => 'Setting flag: ${flag.name}');
          continue;
        } else {
          throw UnknownFlag(subargument);
        }
      }
      break;
    }

    final scriptList = subarguments.sublist(scriptIndex);

    if (flagSet.isSet(PackageFlag())) {
      await _compilePackage(scriptList);
    } else {
      await compileScripts(scriptList);
    }

    return exitCode;
  }

  ///
  Future<int> compileScript(String scriptPath) async {
    var exitCode = 0;

    print('');
    print(orange('Compiling $scriptPath...'));
    print('');

    RunCommand.validateScriptPath(scriptPath);
    final script = DartScript.fromFile(scriptPath);

    final preparationAllowed = !Shell.current.isSudo;

    if (!preparationAllowed) {
      /// we are running sudo, so we can't init a script
      /// as we will end up with root permissions everywhere.
      if (!script.isReadyToRun) {
        printerr(
          red(
            'The script is not ready to run, so cannot be run from sudo. '
            'Run dcli warmup $scriptPath',
          ),
        );
        dcliExit(1);
      }
    }

    try {
      // by default we warmup the project unless the -np flag is passed.
      // however if the project isn't i a runnable state then we
      // force a build.
      final buildRequired =
          !flagSet.isSet(NoWarmupFlag()) || !script.isReadyToRun;

      print('path: ${script.pathToScript}');
      final project = DartProject.fromPath(script.pathToScriptDirectory);

      if (buildRequired) {
        await project.warmup();
      }

      var install = flagSet.isSet(InstallFlag());
      var overwrite = flagSet.isSet(OverWriteFlag());

      /// if an exe was produced and the --install flag was set.
      /// If no exe then the compile failed.
      if (install && script.isInstalled) {
        if (!overwrite) {
          overwrite = confirm('Overwrite the existing exe?');
          if (!overwrite) {
            install = false;

            print(
              red(
                'The target file ${script.pathToInstalledExe} already exists. '
                'Use the --overwrite flag to overwrite it.',
              ),
            );
          }
        }
      }

      script.compile(install: install, overwrite: overwrite);
    } on RunException catch (e) {
      exitCode = e.exitCode ?? -1;
    }
    return exitCode;
  }

  @override
  String description({bool extended = false}) => '''
Compiles the given list of scripts using dart's native compiler or a a
globally activated package.
   Only required if you want super fast execution.
   If no scripts are passed then all scripts in the current directory are compiled.''';

  @override
  String usage() {
    const description = '''
compile [--nowarmup] [--install] [--overwrite] [<script path.dart>, <script path.dart>,...] | --package <globally activate package name>''';

    return description;
  }

  @override
  List<String> completion(String word) =>
      completionExpandScripts(word, extension: '.dart');

  @override
  List<Flag> flags() => _compileFlags;

  Future<void> compileScripts(List<String> scriptList) async {
    var scriptList0 = scriptList;
    if (scriptList0.isEmpty) {
      scriptList0 = find('*.dart', recursive: false).toList();
    }

    if (scriptList0.isEmpty) {
      throw InvalidCommandArgumentException('There are no scripts to compile.');
    } else {
      // if (flagSet.isSet(WatchFlag())) {
      //   if (scriptList.length != 1) {
      //     throw InvalidArguments('You may only watch a single script');
      //   }
      //   IncrementalCompiler(scriptList.first).watch();
      // } else {
      for (final scriptPath in scriptList0) {
        exitCode = await compileScript(scriptPath);
        if (exitCode != 0) {
          break;
        }
        //}
      }
    }
  }

  /// Compiles a globally activted taking the package name
  /// and optionally the version from [scriptList].
  Future<void> _compilePackage(List<String> scriptList) async {
    // we are compiling a globally activated package
    // we must be passed the package name and optionally a version
    if (scriptList.length != 1 && scriptList.length != 2) {
      throw InvalidCommandArgumentException(
          'The "--package" flag must be followed by '
          'the name of the package and optionally a version');
    }

    final packageName = scriptList[0];
    String? versionString;
    if (scriptList.length == 2) {
      versionString = scriptList[1];
    }

    await compilePackage(packageName, version: versionString);
  }

  /// Compiles a globally activted
  Future<void> compilePackage(String packageName, {String? version}) async {
    if (packageName.contains(separator)) {
      throw InvalidCommandArgumentException(
          'The package must not include a path.');
    }
    if (!PubCache().isInstalled(packageName) &&
        !PubCache().isGloballyActivated(packageName)) {
      throw InvalidCommandArgumentException('''
To compile the package $packageName it must first be installed.
Run:
  dart pub global activate $packageName
  ''');
    }

    if (!exists(Settings().pathToDCli)) {
      throw DCliNotInstalledException(
          "You must first install DCli by running 'dcli install'");
    }

    late final String pathToPackage;

    /// Find all the the exectuables the package exposes
    if (version == null) {
      late final version = PubCache().findPrimaryVersion(packageName);
      pathToPackage =
          PubCache().pathToPackage(packageName, version?.toString() ?? '');
    } else {
      final pathTo = PubCache().findVersion(packageName, version);
      if (pathTo == null) {
        throw InvalidCommandArgumentException(
            'The requested version $version does not exist');
      }
      pathToPackage = pathTo;
    }

    await core.withTempDirAsync((pathToTempPackage) async {
      /// we copy the package to a temp area so we don't
      /// contaminate the cache. Don't know if this is actually
      /// a problem..
      print('Creating temp copy of package $packageName ${version ?? ""}');
      copyTree(pathToPackage, pathToTempPackage,

          /// dart allows a user to publish the override even though it should
          /// never be published and breaks build from cache if it exists.
          filter: (file) => basename(file) != 'pubspec_overrides.yaml');
      await DartProject.fromPath(pathToTempPackage).warmup();

      final pubspec = PubSpec.load(directory: pathToTempPackage);

      for (final exe in pubspec.executables.list) {
        final pathToOutput =
            join(pathToTempPackage, dirname(exe.scriptPath), exe.name);
        print(green('Compiling ${exe.name}...'));
        DartSdk().runDartCompiler(
          DartScript.fromFile(join(pathToTempPackage, exe.scriptPath)),
          pathToExe: pathToOutput,
          progress: Progress(print, stderr: print),
          workingDirectory: pathToTempPackage,
        );
        move(pathToOutput, Settings().pathToDCliBin, overwrite: true);
      }
    });
  }
}

///
class NoWarmupFlag extends Flag {
  ///
  NoWarmupFlag() : super(_flagName);
  static const _flagName = 'nowarmup';

  @override
  String get abbreviation => 'nw';

  @override
  String description() => '''
      Stops the compile from running 'dcli warmup' before compiling.
      Use the nowarmup option to speed up compilation when you know your project structure is up to date.''';
}

///
class InstallFlag extends Flag {
  ///
  InstallFlag() : super(_flagName);

  static const _flagName = 'install';

  @override
  String get abbreviation => 'i';

  @override
  String description() => '''
      Installs the compiled script into your path '''
      '${Settings().pathToDCliBin}';
}

///
class OverWriteFlag extends Flag {
  ///
  OverWriteFlag() : super(_flagName);
  static const _flagName = 'overwrite';

  @override
  String get abbreviation => 'o';

  @override
  String description() => '''
      If the installed executable already exists in '
      '${Settings().pathToDCliBin} then it will overwritten.''';
}

///
class PackageFlag extends Flag {
  ///
  PackageFlag() : super(_flagName);
  static const _flagName = 'package';

  @override
  String get abbreviation => 'p';

  @override
  String description() => '''
      Compile a globally installed dart package and adds it to your path '${Settings().pathToDCliBin}'.
      If a version isn't passed then we compile the most recent stable version.
      Run 'dart pub global activate <package name>' 
      Then 'dcli compile --package <package name> [<version>]' ''';
}

/// watch the package for file changes and do
/// incremental compile on the selected scripts.
class WatchFlag extends Flag {
  ///
  WatchFlag() : super(_flagName);
  static const _flagName = 'watch';

  @override
  String get abbreviation => 'w';

  @override
  String description() => '''
      Experimental
      Places the compiler into increment compilation mode. 
     dcli will watch for changes in the script and project automatically re-compiling.''';
}
