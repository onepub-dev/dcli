import 'package:dshell/dshell.dart';
import 'package:dshell/functions/is.dart';
import 'package:dshell/script/project_cache.dart';

import 'package:path/path.dart' as p;

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
    _initTemplates();

    _script = validateArguments(selectedFlags, arguments);

    String body = _script.generateDefaultBody();
    _script.createDefaultFile(body);

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

    return Script.fromArg(arguments[0]);
  }

  /// Checks if the templates directory exists and .dshell and if not creates
  /// the directory and copies the default scripts in.
  void _initTemplates() {
    String templatePath = p.join(ProjectCache().path, "templates");

    if (!exists(templatePath)) {
      createDir(templatePath, createParent: true);
    }
  }

  @override
  String description() =>
      "Creates a script file with a default pubspec annotation and a main entry point.";

  @override
  String usage() => "create <script path.dart>";
}
