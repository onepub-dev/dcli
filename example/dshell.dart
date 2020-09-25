#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

void main(List<String> args) {
  for (;;) {
    var line = ask('${green(basename(pwd))}${blue('>')}');
    if (line.isNotEmpty) {
      dispatch(line);
    }
  }
}

void dispatch(String command) {
  // if (command.contains('|')) {
  //   buildPipe(command);
  // }
  var parts = command.split(' ');
  switch (parts[0]) {
    case 'ls':
      ls(parts.sublist(1));
      break;
    case 'cd':
      Directory.current = join(pwd, parts[1]);
      break;
    default:
      if (which(parts[0]).isNotEmpty) {
        command.run;
      } else {
        print(red('Unknown command: ${parts[0]}'));
      }
      break;
  }
}

// void buildPipe(String line) {
//   var commands = line.split('|');

//   for (var command in commands)

//   var progress = Progress.stream();
//   parts[0].start(
//     progress: progress,
//     runInShell: true,
//   );

//   RunnableProcess();

//   var done = Completer<void>();
//   progress.stream.listen((event) {
//     print('stream: $event');
//   }).onDone(() => done.complete());
//   waitForEx<void>(done.future);
//   print('done');

//   parts[0].stream;
// }

void ls(List<String> patterns) {
  if (patterns.isEmpty) {
    find('*', root: pwd, recursive: false, types: [Find.file, Find.directory])
        .forEach((file) => print(basename(file)));
  } else {
    for (var pattern in patterns) {
      find(pattern,
              root: pwd, recursive: false, types: [Find.file, Find.directory])
          .forEach((file) => print(basename(file)));
    }
  }
}
