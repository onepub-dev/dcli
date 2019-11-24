import '../dart_sdk.dart';
import '../flags.dart';
import '../project.dart';
import '../project_cache.dart';
import '../script.dart';
import 'commands.dart';

class CompileCommand extends Command {
  static const String NAME = "compile";

  CompileCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    Script.validate(subarguments);
    Script script = Script.fromArg(selectedFlags, subarguments[0]);
    try {
      Project project = Project(ProjectCache().cachePath, script);

      // TODO: need an option to allow the user to place the native
      // file as they may not have write access to the script dir.
      String result = DartSdk().runDart2Native(
          script, script.scriptDirectory, project.projectCacheDir);
    } on DartRunException catch (e) {}

    return 0;
  }

  @override
  String description(String appname) =>
      "Compiles the script using darts native compiler. Only required if you want super fast execute";

  @override
  String usage(String appname) => "$appname compile";
}
