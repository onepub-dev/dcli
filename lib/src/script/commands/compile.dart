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

  List<Flag> compileFlags = [NoCleanFlag()];

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  CompileCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var exitCode = 0;

    var scriptIndex = 0;

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
          if (flag == VerboseFlag()) {
            Settings().verbose('DShell Version: ${Settings().version}');
          }
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
      if (!flagSet.isSet(NoCleanFlag())) {
        // make certain the project is upto date.
        project.clean();
      }

      DartSdk().runDart2Native(script, script.scriptDirectory, project.path,
          progress:
              Progress((line) => print(line), stderr: (line) => print(line)));
    } on RunException catch (e) {
      exitCode = e.exitCode;
    }

    return exitCode;
  }

  @override
  String description() =>
      "Compiles the script using dart's native compiler. Only required if you want super fast execution.";

  @override
  String usage() => '''compile [-noclean] <script path.dart>
    ${orange("flags:")}
      ${orange("--noclean | -nc")}
      If set the project will NOT be cleaned before compiling.
      Use the noclean option to speed up compilation when you know your project structure is up to date.
      ''';
}

class NoCleanFlag extends Flag {
  static const NAME = 'noclean';

  NoCleanFlag() : super(NAME);

  @override
  String get abbreviation => 'nc';

  @override
  String description() {
    return "Stops the compile from running 'dshell clean' before compiling.";
  }
}
