import 'package:dshell/src/util/ansi_color.dart';
import 'package:dshell/src/util/completion.dart';
import 'package:dshell/src/util/progress.dart';

import '../../../dshell.dart';
import '../../settings.dart';
import '../command_line_runner.dart';
import '../dart_sdk.dart';
import '../flags.dart';
import '../script.dart';
import '../virtual_project.dart';
import 'commands.dart';
import '../../util/runnable_process.dart';

class CompileCommand extends Command {
  static const String NAME = 'compile';

  List<Flag> compileFlags = [NoCleanFlag(), InstallFlag(), OverWriteFlag()];

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  CompileCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var exitCode = 0;

    var scriptIndex = 0;

    // check for any flags
    for (var i = 0; i < subarguments.length; i++) {
      final subargument = subarguments[i];

      if (Flags.isFlag(subargument)) {
        scriptIndex++;
        var flag = flagSet.findFlag(subargument, compileFlags);

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
      printerr('There are no scripts to compile');
    } else {
      for (var scriptPath in scriptList) {
        exitCode = compileScript(scriptPath);
        if (exitCode != 0) break;
      }
    }

    return exitCode;
  }

  int compileScript(String scriptPath) {
    var exitCode = 0;

    print('');
    print(orange('Compiling $scriptPath...'));
    print('');

    Script.validate(scriptPath);
    var script = Script.fromFile(scriptPath);
    try {
      var project = VirtualProject.load(script);

      // by default we clean the project unless the -nc flagg is passed.
      // however if the project isn't i a runnable state then we
      // force a build.
      var buildRequired = !flagSet.isSet(NoCleanFlag()) || !project.isRunnable;

      if (buildRequired) {
        project.build();
      }

      Settings().verbose(
          "\nCompiling with pubspec.yaml:\n${read(project.runtimePubSpecPath).toList().join('\n')}\n");

      DartSdk().runDart2Native(project.runtimeScriptPath,
          script.scriptDirectory, project.runtimeProjectPath,
          progress:
              Progress((line) => print(line), stderr: (line) => print(line)));

      var exe = join(script.scriptDirectory, script.basename);

      /// if an exe was produced and the --install flag was set.
      /// If no exe then the compile failed.
      if (flagSet.isSet(InstallFlag()) && exists(exe)) {
        var install = true;
        var to = join(Settings().dshellBinPath, script.basename);
        if (exists(to) && !flagSet.isSet(OverWriteFlag())) {
          install = false;
          print(red(
              'The target file $to already exists. Use the --overwrite flag to overwrite it.'));
        }

        if (install) {
          print('');
          print(orange('Installing $exe into $to'));
          move(exe, to);
        }
      }
    } on RunException catch (e) {
      exitCode = e.exitCode;
    }
    return exitCode;
  }

  @override
  String description() =>
      '''Compiles the given list of scripts using dart's native compiler. 
   Only required if you want super fast execution.
   If no scripts are passed then all scripts in the current directory are compiled.
      ''';

  @override
  String usage() {
    var description =
        '''compile [--noclean] [--install] [--overwrite] [<script path.dart>, <script path.dart>,...]''';

    return description;
  }

  @override
  List<String> completion(String word) {
    return completion_expand_scripts(word);
  }

  @override
  List<Flag> flags() {
    return compileFlags;
  }
}

class NoCleanFlag extends Flag {
  static const NAME = 'noclean';

  NoCleanFlag() : super(NAME);

  @override
  String get abbreviation => 'nc';

  @override
  String description() {
    return '''Stops the compile from running 'dshell clean' before compiling.
      Use the noclean option to speed up compilation when you know your project structure is up to date.''';
  }
}

class InstallFlag extends Flag {
  static const NAME = 'install';

  InstallFlag() : super(NAME);

  @override
  String get abbreviation => 'i';

  @override
  String description() {
    return 'Installs the compiled script into your path ${Settings().dshellBinPath}';
  }
}

class OverWriteFlag extends Flag {
  static const NAME = 'overwrite';

  OverWriteFlag() : super(NAME);

  @override
  String get abbreviation => 'o';

  @override
  String description() {
    return 'If the installed executable already exists in ${Settings().dshellBinPath} then it will overwritten.';
  }
}
