import '../dart_sdk.dart';
import '../flags.dart';
import '../project.dart';
import '../project_cache.dart';
import '../script.dart';
import 'commands.dart';
import '../../util/runnable_process.dart';

class CompileCommand extends Command {
  static const String NAME = "compile";

  CompileCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    int exitCode = 0;
    Script.validate(subarguments);
    Script script = Script.fromArg(selectedFlags, subarguments[0]);
    try {
      VirtualProject project = VirtualProject(ProjectCache().path, script);

      // TODO: need an option to allow the user to place the native
      // file as they may not have write access to the script dir.
      DartSdk()
          .runDart2Native(script, script.scriptDirectory, project.path)
          .forEach((line) => print(line), stderr: (line) => print(line));
    } on RunException catch (e) {
      exitCode = e.exitCode;
    }

    return exitCode;
  }

  @override
  String description(String appname) =>
      "Compiles the script using darts native compiler. Only required if you want super fast execute";

  @override
  String usage(String appname) => "$appname compile";
}
