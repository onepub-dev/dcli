import 'package:dshell/script/project_cache.dart';

import '../command_line_runner.dart';
import '../flags.dart';
import '../script.dart';
import 'commands.dart';

class CreateCommand extends Command {
  static const String NAME = "create";

  Script _script;

  CreateCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    _script = validateArguments(selectedFlags, arguments);
    String body = _script.generateDefaultBody("dshell");
    _script.createDefaultFile("dshell", body);

    print("Creating project.");
    ProjectCache().createProject(_script);

    print("Project creation complete.");
    print("To run your script:\n   dshell ${_script.scriptname}");

    return 0;
  }

  Script validateArguments(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.length != 1) {
      throw InvalidArguments(
          "The create command takes only one argument. Found: ${arguments.join(",")}");
    }

    return Script.fromArg(selectedFlags, arguments[0]);
  }

  @override
  String description(String appname) =>
      "Creates a script file with a default pubspec annotation and a main entry point.";

  @override
  String usage(String appname) => "$appname create <script path.dart>";
}
