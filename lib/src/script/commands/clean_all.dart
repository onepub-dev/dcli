import '../flags.dart';
import '../project_cache.dart';
import 'commands.dart';

class CleanAllCommand extends Command {
  static const String NAME = 'cleanall';

  CleanAllCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    ProjectCache().cleanAll();
    return 0;
  }

  @override
  String usage() => 'cleanall';

  @override
  String description() =>
      "Delete the project cache for all scripts. The script's project cache will be rebuilt when the script is next run.";
}
