import '../../../dcli.dart';
import '../../functions/which.dart';
import '../../settings.dart';
import '../../util/ansi_color.dart';
import '../../util/dcli_paths.dart';
import '../../util/recase.dart';
import '../../util/runnable_process.dart';
import '../command_line_runner.dart';
import '../flags.dart';
import 'commands.dart';

///
class VersionCommand extends Command {
  static const String _commandName = 'version';

  ///
  VersionCommand() : super(_commandName);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    if (subarguments.isNotEmpty) {
      throw InvalidArguments(
          "'dcli version' does not take any arguments. Found $subarguments");
    }

    var appname = DCliPaths().dcliName;

    var location = which(appname, first: true).firstLine;

    if (location == null) {
      printerr(red('Error: dcli is not on your path. Run "dcli install"'));
    }

    print(green(
        '${ReCase.titleCase(appname)} Version: ${Settings().version}, Located at: $location'));

    return 0;
  }

  @override
  String description() =>
      """Running 'dcli version' displays the dcli version and path.""";

  @override
  String usage() => 'Version';

  @override
  List<String> completion(String word) {
    return <String>[];
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
