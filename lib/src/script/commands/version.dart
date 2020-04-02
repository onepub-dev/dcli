import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/dshell_paths.dart';
import 'package:dshell/src/util/runnable_process.dart';
import 'package:recase/recase.dart';

import '../../functions/which.dart';
import '../command_line_runner.dart';
import '../../settings.dart';
import '../../util/ansi_color.dart';

import '../flags.dart';
import 'commands.dart';

class VersionCommand extends Command {
  static const String NAME = 'version';

  VersionCommand() : super(NAME);

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
        '${ReCase(appname).sentenceCase} Version: ${Settings().version}, Located at: $location'));

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
