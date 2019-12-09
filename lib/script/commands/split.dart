import '../command_line_runner.dart';
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
    Script.fromFile(subarguments[0]);

    return 0;
  }

  @override
  String description() =>
      "Removes the pubspec annotation from your scripts and saves it to a pubspec.yaml file. Use this option when you project starts to grow.";

  @override
  String usage() => "split <script path.dart>";
}
