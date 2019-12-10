import '../../settings.dart';
import '../dart_sdk.dart';
import '../flags.dart';
import '../script.dart';
import '../virtual_project.dart';
import 'commands.dart';
import '../../util/runnable_process.dart';

class CompileCommand extends Command {
  static const String NAME = "compile";

  CompileCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    int exitCode = 0;
    Script.validate(subarguments);
    Script script = Script.fromFile(subarguments[0]);
    try {
      VirtualProject project = VirtualProject(Settings().cachePath, script);

      DartSdk()
          .runDart2Native(script, script.scriptDirectory, project.path)
          .forEach((line) => print(line), stderr: (line) => print(line));
    } on RunException catch (e) {
      exitCode = e.exitCode;
    }

    return exitCode;
  }

  @override
  String description() =>
      "Compiles the script using dart's native compiler. Only required if you want super fast execution.";

  @override
  String usage() => "compile <script path.dart>";
}
