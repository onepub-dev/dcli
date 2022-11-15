/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import '../../../dcli.dart';
import '../../util/completion.dart';
import '../command_line_runner.dart';
import '../flags.dart';
import 'commands.dart';

/// implementation for the compile command.
class CompileCommand extends Command {
  ///
  CompileCommand() : super(_commandName);
  static const String _commandName = 'compile';

  final _compileFlags = [
    NoWarmupFlag(),
    InstallFlag(),
    OverWriteFlag(),
    //WatchFlag()
  ];

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
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

    if (scriptList.isNotEmpty && scriptList[0] == 'package') {
      // we are compiling a globally activated package.
      if (scriptList.length != 2) {
        throw InvalidArgumentException(
            'The "package" command must be followed by '
            'the name of the package');
      }

      compilePackage(scriptList[1]);
    } else {
      compileScripts(scriptList);
    }

    return exitCode;
  }

  ///
  int compileScript(String scriptPath) {
    var exitCode = 0;

    print('');
    print(orange('Compiling $scriptPath...'));
    print('');

    DartScript.validate(scriptPath);
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
        project.warmup();
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
Compiles the given list of scripts using dart's native compiler. 
   Only required if you want super fast execution.
   If no scripts are passed then all scripts in the current directory are compiled.''';

  @override
  String usage() {
    const description =
        'compile [--nowarmup] [--install] [--overwrite] [<script path.dart>, '
        '<script path.dart>,...]';

    return description;
  }

  @override
  List<String> completion(String word) =>
      completionExpandScripts(word, extension: '.dart');

  @override
  List<Flag> flags() => _compileFlags;

  void compileScripts(List<String> scriptList) {
    var _scriptList = scriptList;
    if (_scriptList.isEmpty) {
      _scriptList = find('*.dart', recursive: false).toList();
    }

    if (_scriptList.isEmpty) {
      throw InvalidArgumentException('There are no scripts to compile.');
    } else {
      // if (flagSet.isSet(WatchFlag())) {
      //   if (scriptList.length != 1) {
      //     throw InvalidArguments('You may only watch a single script');
      //   }
      //   waitForEx(IncrementalCompiler(scriptList.first).watch());
      // } else {
      for (final scriptPath in _scriptList) {
        exitCode = compileScript(scriptPath);
        if (exitCode != 0) {
          break;
        }
        //}
      }
    }
  }

  /// Compiles a globally activted
  void compilePackage(String packageName) {
    if (!PubCache().isInstalled(packageName) ||
        !PubCache().isGloballyActivated(packageName)) {
      throw ArgumentError('To compile the package $packageName '
          'it must first be installed. Run pub global activate $packageName');
    }

    /// Find all the the exectuables the package exposes
    final version = PubCache().findPrimaryVersion(packageName);
    assert(version != null, 'If a package exists there must be a version');

    final pathToPackage =
        PubCache().pathToPackage(packageName, version.toString());

    withTempDir((pathToTempPackage) {
      /// we copy the package to a temp area so we don't
      /// contaminate the cache. Don't know if this is actually
      /// a problem..
      print('Creating temp copy of package');
      copyTree(pathToPackage, pathToTempPackage);
      DartProject.fromPath(pathToTempPackage).warmup();

      final pubspec = PubSpec.fromFile(join(pathToTempPackage, 'pubspec.yaml'));

      for (final exe in pubspec.executables) {
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
