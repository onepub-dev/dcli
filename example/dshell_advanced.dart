#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

/// A toy REPL shell to replace your bash command line in just 50 lines of dart.
///
/// This work in progress will show how to implement a pipe command.
void main(List<String> args) {
  // Loop, asking for user input and evaluating it
  for (;;) {
    final line = ask('${green(basename(pwd))}${blue('>')}');
    if (line.isNotEmpty) {
      evaluate(line);
    }
  }
}

// Evaluate the users input
void evaluate(String command) {
  // if (command.contains('|')) {
  //   buildPipe(command);
  // }
  final parts = command.split(' ');
  switch (parts[0]) {
    case 'ls':
      ls(parts.sublist(1));
      break;
    case 'cd':
      Directory.current = join(pwd, parts[1]);
      break;
    default:
      if (which(parts[0]).found) {
        command.run;
      } else {
        print(red('Unknown command: ${parts[0]}'));
      }
      break;
  }
}

/// our own implementation of the 'ls' command.
void ls(List<String> patterns) {
  if (patterns.isEmpty) {
    find('*', root: pwd, recursive: false, types: [Find.file, Find.directory])
        .forEach((file) => print('  $file'));
  } else {
    for (final pattern in patterns) {
      find(pattern,
              root: pwd, recursive: false, types: [Find.file, Find.directory])
          .forEach((file) => print('  $file'));
    }
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
