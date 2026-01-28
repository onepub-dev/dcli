#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

/// A toy REPL shell to replace your bash command line in just 50 lines of dart.
/// @Throwing(ArgumentError)
/// @Throwing(UnsupportedError)
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
/// @Throwing(ArgumentError)
/// @Throwing(UnsupportedError)
void evaluate(String command) {
  final parts = command.split(' ');
  switch (parts[0]) {
    case 'ls':
      ls(parts.sublist(1));
    case 'cd':
      Directory.current = join(pwd, parts[1]);
    case 'exit':
      exit(0);
    default:
      if (which(parts[0]).found) {
        command.start(nothrow: true, progress: Progress.print());
      } else {
        print(red('Unknown command: ${parts[0]}'));
      }
  }
}

/// our own implementation of the 'ls' command.
void ls(List<String> patterns) {
  if (patterns.isEmpty) {
    find(
      '*',
      workingDirectory: pwd,
      recursive: false,
      types: [Find.file, Find.directory],
    ).forEach((file) => print('  $file'));
  } else {
    for (final pattern in patterns) {
      find(
        pattern,
        workingDirectory: pwd,
        recursive: false,
        types: [Find.file, Find.directory],
      ).forEach((file) => print('  $file'));
    }
  }
}
