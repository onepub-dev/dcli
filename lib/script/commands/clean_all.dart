import '../flags.dart';
import '../project_cache.dart';
import 'commands.dart';

class CleanAllCommand extends Command {
  static const String NAME = "cleanall";

  CleanAllCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    ProjectCache().cleanAll();
    return 0;
  }

  String usage(String appname) => "$appname cleanall <script path.dart>";

  String description(String appname) =>
      "Cleans the project caches for all scripts. The project caches for each scripts will be rebuilt at their next run.";
}
