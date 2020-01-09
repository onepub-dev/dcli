import 'package:dshell/src/script/commands/commands.dart';

void main(List<String> args) {
  assert(args.length == 3);
  //var appname = args[0];
  var word = args[1];
  var priorWord = args[2];

  var commands = Commands.applicationCommands;

  var priorCommand = Commands.findCommand(
      priorWord, Commands.asMap(Commands.applicationCommands));

  var results = <String>[];
  if (priorCommand != null) {
    results = priorCommand.completion(word);
  } else {
    // find any command that matches the 'word' using it as prefix
    var results = <String>[];

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
