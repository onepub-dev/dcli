import 'dart:io';

import 'package:dcli/src/script/commands/commands.dart';

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
        'dcli_complete provides tab completion from the bash command line for dcli');
    print("You don't run dcli_complete directly");
    exit(-1);
  }

  //var appname = args[0];
  var word = args[1];

  var commands = Commands.applicationCommands;

  var results = <String>[];

  var priorCommandFound = false;

  // do we have a prior word.
  if (args.length == 3) {
    var priorWord = args[2];
    //print('prior word: $priorWord');
    if (priorWord.isNotEmpty) {
      var priorCommand = Commands.findCommand(
          priorWord, Commands.asMap(Commands.applicationCommands));

      if (priorCommand != null) {
        //print('priorCommand ${priorCommand.name}');
        results = priorCommand.completion(word);
        priorCommandFound = true;
      }
    }
  }

  if (!priorCommandFound) {
    // find any command that matches the 'word' using it as prefix

    for (var command in commands) {
      if (command.name.startsWith(word)) {
        results.add(command.name);
      }
    }
  }
  for (var result in results) {
    print(result);
  }
}

// void install() {
//   print('installing dcli');
//   'dart2native dcli_complete.dart --output=dcli_complete.dart --output=${join(HOME, ".dcli/bin/dcli_complete")}'
//       .run;
// }
