import '../../settings.dart';
import '../../util/ansi_color.dart';
import '../command_line_runner.dart';
import '../flags.dart';
import 'commands.dart';

///
class HelpCommand extends Command {
  static const String _commandName = 'help';

  ///
  HelpCommand() : super(_commandName);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    if (subarguments.isNotEmpty) {
      var command = Commands.findCommand(
          subarguments[0], Commands.asMap(Commands.applicationCommands));
      if (command == null) {
        throw InvalidArguments(
            'help expected a command name. Found $subarguments');
      }
      command.usage();
    }
    _printUsage();
    return 0;
  }

  @override
  String description() =>
      "Displays the usage message | Display the command's usage message.";

  @override
  String usage() => 'help | help <command>';

  /// Print the help usage statement.
  static void printUsageHowTo() {
    var help = HelpCommand();
    print('For help with dshell options:');
    print('  ${Settings().appname} ${help.usage()}');
    print('    ${help.description()}');
  }

  void _printUsage() {
    var appname = Settings().appname;
    print(green(
        '$appname: Executes Dart scripts.  Version: ${Settings().version}'));
    print('');
    print('Example: ');
    print('   dshell hello_world.dart');
    print('   dshell -v compile -nc hello_world.dart');
    print('');
    print(green('Usage:'));
    print(
        '  dshell [${blue('flag, flag...')}] [${blue('command')}] [arguments...]');
    print('');
    print(blue('global flags:'));
    for (var flag in CommandLineRunner.globalFlags) {
      print('  ${blue(flag.usage())}');
      print('      ${flag.description()}');
    }

    print('');
    print(orange('Commands:'));
    for (var command in Commands.applicationCommands) {
      print('  ${orange(command.usage())}');
      print('   ${command.description()}');
      if (command.flags().isNotEmpty) {
        print('');
        print('   ${blue("flags:")}');
      }
      var first = true;
      command.flags().forEach((flag) {
        if (!first) print('');
        first = false;
        print(blue('    ${flag.usage()}'));
        print('      ${flag.description()}');
      });
      print('');
    }
  }

  @override
  List<String> completion(String word) {
    // find any command that matches the 'word' using it as prefix
    var results = <String>[];

    var commands = Commands.applicationCommands;
    for (var command in commands) {
      if (command.name.startsWith(word)) {
        results.add(command.name);
      }
    }

    return results;
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
