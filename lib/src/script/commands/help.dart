import '../command_line_runner.dart';

import '../../settings.dart';
import '../flags.dart';
import 'commands.dart';
import '../../util/ansi_color.dart';

class HelpCommand extends Command {
  static const String NAME = 'help';

  HelpCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    if (subarguments.isNotEmpty) {
      var command = Commands.findCommand(
          subarguments[0], Commands.asMap(Commands.applicationCommands));
      if (command == null) {
        throw InvalidArguments(
            'help expected a command name. Found ${subarguments}');
      }
      command.usage();
    }
    printUsage();
    return 0;
  }

  @override
  String description() =>
      'Displays the usage message | Display the commands usage message.';

  @override
  String usage() => 'help | help <command>';

  void printUsage() {
    var appname = Settings().appname;
    print(green('$appname: Executes Dart scripts'));
    print('');
    print(yellow('Example: '));
    print(yellow('   dshell hello_world.dart'));
    print('');
    print(green('Usage:'));
    print(
        '  dshell [${orange('flag, flag...')}] [${blue('command')}] [arguments...]');
    print('');
    print(orange('Flags:'));
    for (var flag in Flags.applicationFlags) {
      print('  ' + orange(flag.usage()));
      print('    ' + flag.description());
    }

    print('');
    print(blue('Commands:'));
    for (var command in Commands.applicationCommands) {
      print('');
      print('  ' + blue(command.usage()));
      print('   ' + command.description());
    }
  }
}
