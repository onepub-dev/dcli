# dshell

The dshell example demonstrates building a toy command line shell \(just like Bash\).

It has two built in commands \(ls and cd\) and allows you to run any other CLI command.

```dart
#! /usr/bin/env dcli

import 'dart:async';
import 'dart:io';

import 'package:dcli/dcli.dart';

void main(List<String> args) {
  /// loop forever, ask for user input and then dispatch it.
  for (;;) {
    var line = ask('${green(basename(pwd))}${blue('>')}');
    if (line.isNotEmpty) {
      dispatch(line);
    }
  }
}

/// dispatches the command the user entered.
void dispatch(String command) {

  var parts = command.split(' ');
  switch (parts[0]) {
    /// run ls
    case 'ls':
      ls(parts.sublist(1));
      break;
    /// change directory
    case 'cd':
      Directory.current = join(pwd, parts[1]);
      break;
      
    /// run any other command that is on  the path.
    default:
      if (which(parts[0]).firstLine != null) {
        command.run;
      } else {
        print(red('Unknown command: ${parts[0]}'));
      }
      break;
  }
}

/// Implementation of the 'ls' command using dcli's 'find' function.
void ls(List<String> patterns) {
  if (patterns.isEmpty) {
    find('*',
            root: pwd,
            types: [Find.file, Find.directory])
        .forEach((file) => print(file));
  } else {
    for (var pattern in patterns) {
      find(pattern, root: pwd, types: [
        Find.file,
        Find.directory
      ]).forEach((file) => print(file));
    }
  }
}

```

