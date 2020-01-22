import 'package:dshell/src/util/ansi_color.dart';
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
      scriptIndex = i;
      Script.validate(subarguments.sublist(scriptIndex));
      break;
    }
    var script = Script.fromFile(subarguments[scriptIndex]);
    try {
      var project = VirtualProject(Settings().cachePath, script);

      // by default we clean the project unless the -nc flagg is passed.
      // howver if the project doesn't exist we force a clean
      if (!flagSet.isSet(NoCleanFlag())) {
        // make certain the project is upto date.
        project.clean();
      }

      if (!exists(project.path)) {
        print("Running 'clean' as Virtual Project does not exist.");
        project.clean();
      }

      Settings().verbose(
          "\nCompling with pubspec.yaml:\n${read(join(project.path, 'pubspec.yaml')).toList().join('\n')}\n");

      DartSdk().runDart2Native(script, script.scriptDirectory, project.path,
          progress:
              Progress((line) => print(line), stderr: (line) => print(line)));

      if (flagSet.isSet(InstallFlag())) {
        var install = true;
        var to = join(Settings().dshellBinPath, script.basename);
        var from = join(script.scriptDirectory, script.basename);
        if (exists(to) && !flagSet.isSet(OverWriteFlag())) {
          install = false;
          print(red(
              'The target file $to already exists. Use the --overwrite flag to overwrite it.'));
        }

        if (install) {
          print('');
          print(orange('Installing $from into $to'));
          move(from, to);
        }
      }
    } on RunException catch (e) {
      exitCode = e.exitCode;
    }

    return exitCode;
  }

  @override
  String description() =>
      "Compiles the script using dart's native compiler. Only required if you want super fast execution.";

  @override
  String usage() {
    var description =
        '''compile [--noclean] [--install] [--overwrite] <script path.dart>''';

    return description;
  }

  @override
  List<String> completion(String word) {
    var dartScripts = find('*.dart', recursive: false).toList();
    var results = <String>[];
    for (var script in dartScripts) {
      if (script.startsWith(word)) {
        results.add(script);
      }
    }
    return results;
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
