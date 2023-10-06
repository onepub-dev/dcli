/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_sdk/src/commands/commands.dart';
import 'package:dcli_sdk/src/util/exit.dart';

/// provides command line tab completion for bash users.
///
/// For details on how bash does auto completion see:
/// https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion-Builtins.html
///
/// This application is installed by dcli install as a command for the
/// bash 'complete' application.
///
/// When typing a dcli command on the cli, if the user hits tab twice bash
/// will call this application with 2 or three arguments
/// args[0] will always contain the application name 'dcli'
/// args[1] will contain the current word being typed
/// args[2] if provided will contain the prior word in the command line

void main(List<String> args) {
  if (args.length < 2) {
    print(
      'dcli_complete provides tab completion '
      'from the bash command line for dcli',
    );
    print("You don't run dcli_complete directly");
    dcliExit(-1);
  }

  //var appname = args[0];
  final word = args[1];

  final commands = Commands.applicationCommands;

  var results = <String>[];

  var priorCommandFound = false;

  // do we have a prior word.
  if (args.length == 3) {
    final priorWord = args[2];
    //print('prior word: $priorWord');
    if (priorWord.isNotEmpty) {
      final priorCommand = Commands.findCommand(
        priorWord,
        Commands.asMap(Commands.applicationCommands),
      );

      if (priorCommand != null) {
        //print('priorCommand ${priorCommand.name}');
        results = priorCommand.completion(word);
        priorCommandFound = true;
      }
    }
  }

  if (!priorCommandFound) {
    // find any command that matches the 'word' using it as prefix

    for (final command in commands) {
      if (command.name.startsWith(word)) {
        results.add(command.name);
      }
    }
  }
  results.forEach(print);
}
