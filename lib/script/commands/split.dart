import '../args.dart';
import '../flags.dart';
import '../script.dart';
import 'commands.dart';

class SplitCommand extends Command {
  static const String NAME = "split";

  SplitCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    if (subarguments.isEmpty) {
      throw InvalidArguments("Split requires a argument <script file.dart>");
    }
    Script.validate(subarguments);
    Script.fromArg(selectedFlags, subarguments[0]);

    return 0;
  }

  @override
  String description(String appname) =>
      "Removes the pubspec annotation from your scripts and saves it to a pubspec.yaml file. Use this option when you project starts to grow.";

  @override
  String usage(String appname) => "$appname split";
}
