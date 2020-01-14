import '../../../dshell.dart';
import '../../functions/is.dart';
import '../project_cache.dart';

import 'package:path/path.dart' as p;

import '../command_line_runner.dart';
import '../flags.dart';
import '../script.dart';
import 'commands.dart';

class CreateCommand extends Command {
  static const String NAME = 'create';

  Script _script;

  CreateCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    _initTemplates();

    _script = validateArguments(selectedFlags, arguments);

    var body = _script.generateDefaultBody();
    _script.createDefaultFile(body);

    print('Creating project.');
    ProjectCache().createProject(_script);

    print('Making script executable');
    chmod(755, p.join(_script.scriptDirectory, _script.scriptname));

    print('Project creation complete.');

    print('To run your script:\n   ./${_script.scriptname}');

    return 0;
  }

  Script validateArguments(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.length != 1) {
      throw InvalidArguments(
          'The create command takes only one argument. Found: ${arguments.join(',')}');
    }
    var scriptName = arguments[0];
    if (extension(scriptName) != '.dart') {
      throw InvalidArguments(
          "The create command expects a script name ending in '.dart'. Found: ${scriptName}");
    }

    return Script.fromFile(arguments[0]);
  }

  /// Checks if the templates directory exists and .dshell and if not creates
  /// the directory and copies the default scripts in.
  void _initTemplates() {
    if (!exists(Settings().templatePath)) {
      createDir(Settings().templatePath, recursive: true);
    }
  }

  @override
  String description() =>
      'Creates a script file with a default pubspec annotation and a main entry point.';

  @override
  String usage() => 'create <script path.dart>';

  @override
  List<String> completion(String word) {
    return <String>[];
  }
}
