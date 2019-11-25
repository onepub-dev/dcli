import '../dart_sdk.dart';
import '../flags.dart';
import '../project.dart';
import '../project_cache.dart';
import '../runner.dart';
import '../script.dart';
import 'commands.dart';

/// Runs a dart script.
class RunCommand extends Command {
  static const String NAME = "run";

  RunCommand() : super(NAME);

  ///
  /// [arguments] - the arguments passed directly to the run command.
  /// Returns the [exitcode];
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    Script.validate(arguments);

    Script script = Script.fromArg(selectedFlags, arguments[0]);

    VirtualProject project = ProjectCache().createProject(script);
    List<String> scriptArguments = List();

    if (arguments.length > 1) {
      scriptArguments = arguments.sublist(1);
    }

    final DartSdk sdk = DartSdk();
    final ScriptRunner runner = ScriptRunner(sdk, project, scriptArguments);

    final int exitCode = runner.exec();

    return exitCode;
  }

  String usage(String appname) => "$appname run <script path.dart>";

  String description(String appname) =>
      "Runs the given script. This command is provided for the sake of symetry. The recommended method is is to use the simplier form $appname <script path.dart>";

  // CommandRun.fromScriptArg(String argument) {
  //   Script.validate(argument);
  //   Script script = Script.fromArg(selectedFlags.values.toList(), argument);
  //   script.run(selectedFlags, subarguments);
  // }
}
