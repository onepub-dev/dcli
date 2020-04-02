import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/completion.dart';

import '../../settings.dart';
import '../command_line_runner.dart';
import '../dart_sdk.dart';
import '../flags.dart';
import '../runner.dart';
import '../script.dart';
import '../virtual_project.dart';
import 'commands.dart';

/// Runs a dart script.
/// If required a virtual project is created
/// and built.
class RunCommand extends Command {
  static const String NAME = 'run';

  RunCommand() : super(NAME);

  ///
  ///
  /// [arguments] - the arguments passed directly to the run command.
  /// Returns the [exitcode];
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.isEmpty) {
      throw InvalidArguments(
          'Expected a script or command. No arguments were found.');
    }
    var scriptPath = arguments[0];
    Script.validate(scriptPath);

    var script = Script.fromFile(scriptPath);
    Settings().scriptPath = script.path;

    Settings().verbose('Running script ${script.path}');

    var project = VirtualProject.load(script);
    Settings()
        .verbose('Virtual Project directory ${project.runtimeProjectPath}');

    if (!project.isRunnable) {
      project.build();
    }

    var scriptArguments = <String>[];

    if (arguments.length > 1) {
      scriptArguments = arguments.sublist(1);
    }

    Settings().verbose('Script Arguments: ${scriptArguments.join(", ")}');

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

  @override
  List<String> completion(String word) {
    return completion_expand_scripts(word);
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
