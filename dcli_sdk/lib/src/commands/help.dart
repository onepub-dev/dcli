/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';

import '../script/command_line_runner.dart';
import '../script/flag.dart';
import '../util/exceptions.dart';
import '../version/version.g.dart';
import 'commands.dart';

///
class HelpCommand extends Command {
  static const _commandName = 'help';

  ///
  HelpCommand() : super(_commandName);

  /// @Throwing(InvalidCommandArgumentException)
  @override
  Future<int> run(List<Flag> selectedFlags, List<String> subarguments) async {
    if (subarguments.isNotEmpty) {
      final command = Commands.findCommand(
        subarguments[0],
        Commands.asMap(Commands.applicationCommands),
      );
      if (command == null) {
        throw InvalidCommandArgumentException(
          'help expected a command name. Found $subarguments',
        );
      }
      print('''
${green('dcli ${command.usage()}')}

${command.description(extended: true)}
''');
      command.flags().forEach((flag) {
        print('''
${blue('    ${flag.usage()}')}
${flag.description()}
''');
      });
    } else {
      _printUsage();
    }
    return 0;
  }

  @override
  String description({bool extended = false}) =>
      "Displays the usage message | Display the command's usage message.";

  @override
  String usage() => 'help | help <command>';

  /// Print the help usage statement.
  static void printUsageHowTo() {
    final help = HelpCommand();
    print('dcli version $packageVersion');
    print('');
    print('For help with dcli options:');
    print('  ${Settings.dcliAppName} ${help.usage()}');
    print('    ${help.description()}');
  }

  void _printUsage() {
    const appname = Settings.dcliAppName;
    print(
      green(
        '$appname: Executes Dart scripts.  Version: ${Settings().version}',
      ),
    );
    print('');
    print('Example: ');
    print('   dcli hello_world.dart');
    print('   dcli -v compile -nc hello_world.dart');
    print('');
    print(green('Usage:'));
    print(
      '  ${orange('dcli')} [${blue('flag.')}..] '
      '[${orange('command')}] [${blue('flag')}...] [arguments...]',
    );
    print('');
    print(blue('global flags:'));
    for (final flag in CommandLineRunner.globalFlags) {
      print('  ${blue(flag.usage())}');
      print(flag.description());
    }

    print('');
    print(orange('Commands:'));
    for (final command in Commands.applicationCommands) {
      print('  ${orange(command.usage())}');
      print('   ${command.description()}');
      if (command.flags().isNotEmpty) {
        print('');
        print('   ${blue("flags:")}');
      }
      var first = true;
      command.flags().forEach((flag) {
        if (!first) {
          print('');
        }
        first = false;
        print(blue('    ${flag.usage()}'));
        print(flag.description());
      });
      print('');
    }
  }

  @override
  List<String> completion(String word) {
    // find any command that matches the 'word' using it as prefix
    final results = <String>[];

    final commands = Commands.applicationCommands;
    for (final command in commands) {
      if (command.name.startsWith(word)) {
        results.add(command.name);
      }
    }

    return results;
  }

  @override
  List<Flag> flags() => [];
}
