import '../../../dshell.dart';
import '../../functions/which.dart';
import '../../settings.dart';
import '../../util/ansi_color.dart';
import '../../util/dshell_paths.dart';
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
          "'dshell version' does not take any arguments. Found $subarguments");
    }

    var appname = DShellPaths().dshellName;

    var location = which(appname, first: true).firstLine;

    if (location == null) {
      printerr(red('Error: dshell is not on your path. Run "dshell install"'));
    }

    print(green(
        '${ReCase.titleCase(appname)} Version: ${Settings().version}, Located at: $location'));

    return 0;
  }

  @override
  String description() =>
      """Running 'dshell version' displays the dshell version and path.""";

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
