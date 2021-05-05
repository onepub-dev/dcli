import 'dart:io';

import '../../../dcli.dart';
import '../../settings.dart';
import '../../util/ansi_color.dart';
import '../../util/completion.dart';
import '../../util/runnable_process.dart';
import '../command_line_runner.dart';
import '../dart_project.dart';
import '../flags.dart';
import '../script.dart';
import 'commands.dart';

/// implementation for the compile command.
class CompileCommand extends Command {
  ///
  CompileCommand() : super(_commandName);
  static const String _commandName = 'compile';

  final _compileFlags = [NoWarmupFlag(), InstallFlag(), OverWriteFlag()];

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var exitCode = 0;

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
          Settings().verbose('Setting flag: ${flag.name}');
          continue;
        } else {
          throw UnknownFlag(subargument);
        }
      }
      break;
    }

    var scriptList = subarguments.sublist(scriptIndex);

    if (scriptList.isEmpty) {
      scriptList = find('*.dart', recursive: false).toList();
    }

    if (scriptList.isEmpty) {
      throw InvalidArguments('There are no scripts to compile.');
    } else {
      for (final scriptPath in scriptList) {
        exitCode = compileScript(scriptPath);
        if (exitCode != 0) {
          break;
        }
      }
    }

    return exitCode;
  }

  ///
  int compileScript(String scriptPath) {
    var exitCode = 0;

    print('');
    print(orange('Compiling $scriptPath...'));
    print('');

    Script.validate(scriptPath);
    final script = Script.fromFile(scriptPath);

    final preparationAllowed = !Shell.current.isSudo;

    if (!preparationAllowed) {
      /// we are running sudo, so we can't init a script
      /// as we will end up with root permissions everywhere.
      if (!script.isReadyToRun) {
        printerr(
            red('The script is not ready to run, so cannot be run from sudo. '
                'Run dcli warmup $scriptPath'));
        exit(1);
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

            print(red(
                'The target file ${script.pathToInstalledExe} already exists. '
                'Use the --overwrite flag to overwrite it.'));
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
  String description() => '''
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
  List<String> completion(String word) => completionExpandScripts(word);

  @override
  List<Flag> flags() => _compileFlags;
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
  String description() => 'Installs the compiled script into your path '
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
  String description() => 'If the installed executable already exists in '
      '${Settings().pathToDCliBin} then it will overwritten.';
}
