#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';

/// A toy REPL shell to replace your bash command line in just 50 lines of dart.
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
  final parts = command.split(' ');
  switch (parts[0]) {
    case 'ls':
      ls(parts.sublist(1));
      break;
    case 'cd':
      Directory.current = join(pwd, parts[1]);
      break;
    case 'exit':
      exit(0);
      break;
    default:
      if (which(parts[0]).found) {
        command.start(nothrow: true, progress: Progress.print());
      } else {
        print(red('Unknown command: ${parts[0]}'));
      }
      break;
  }
}

/// our own implementation of the 'ls' command.
void ls(List<String> patterns) {
  if (patterns.isEmpty) {
    find('*', workingDirectory: pwd, recursive: false, types: [Find.file, Find.directory])
        .forEach((file) => print('  $file'));
  } else {
    for (final pattern in patterns) {
      find(pattern,
              workingDirectory: pwd, recursive: false, types: [Find.file, Find.directory])
          .forEach((file) => print('  $file'));
    }
  }
}
