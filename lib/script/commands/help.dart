import '../../settings.dart';
import '../flags.dart';
import 'commands.dart';

class HelpCommand extends Command {
  static const String NAME = "help";

  HelpCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    if (subarguments.isNotEmpty) {
      Commands.findCommand(
          subarguments[0], Commands.asMap(Commands.applicationCommands));
    }
    printHelp();
    return 0;
  }

  @override
  String description(String appname) => "Displays the usage message.";

  @override
  String usage(String appname) => "$appname help | $appname help <command>";

  void printHelp() {
    print('${Settings().appname}: Executes standalone Dart shell scripts.');
    print('');
    print('Usage: dscript [-v] [-k] [script-filename] [arguments...]');
    print('Example: -v calc.dart 20 + 5');
    print('');
    print('Options:');
    print('-v: Verbose');
    print('-k: Keep temporary project files');
    print('');
    print('');
    print('Sub-commands:');
    print('help: Prints help text');
    print('version: Prints version');
  }

  bool probeSubCommands(List<String> args) {
    if (args.isEmpty) {
      print('Version: ${Settings().version}');
      print('');
      printHelp();
      return true;
    }

    switch (args[0]) {
      case 'version':
        print("${Settings().version}");
        return true;
      case 'help':
        printHelp();
        return true;
    }

    return false;
  }
}
