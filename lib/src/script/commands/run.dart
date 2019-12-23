import '../../pubspec/pubspec_manager.dart';

import '../../settings.dart';
import '../dart_sdk.dart';
import '../flags.dart';
import '../project_cache.dart';
import '../runner.dart';
import '../script.dart';
import 'commands.dart';

/// Runs a dart script.
class RunCommand extends Command {
  static const String NAME = 'run';

  RunCommand() : super(NAME);

  ///
  /// [arguments] - the arguments passed directly to the run command.
  /// Returns the [exitcode];
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    Script.validate(arguments);

    var script = Script.fromFile(arguments[0]);

    var project = ProjectCache().loadProject(script);

    if (PubSpecManager(project).isCleanRequired()) {
      project.clean();
    }

    var scriptArguments = <String>[];

    if (arguments.length > 1) {
      scriptArguments = arguments.sublist(1);
    }

    final sdk = DartSdk();
    final runner = ScriptRunner(sdk, project, scriptArguments);

    final exitCode = runner.exec();

    return exitCode;
  }

  @override
  String usage() => 'run <script path.dart>';

  @override
  String description() =>
      '''Runs the given script. This command is provided for the sake of symmetry. 
 The recommended method is to use the simplier form ${Settings().appname} <script path.dart>''';

  // CommandRun.fromScriptArg(String argument) {
  //   Script.validate(argument);
  //   Script script = Script.fromArg(selectedFlags.values.toList(), argument);
  //   script.run(selectedFlags, subarguments);
  // }
}
