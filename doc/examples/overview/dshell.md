# dshell

The dshell example demonstrates building a toy command line shell \(just like Bash\).

It has three built in commands \(ls,  cd and exit\) and allows you to run any other CLI application that's on your PATH.

To run this script you need to [install dart](../../dcli-tools-1/dcli-install.md)

```yaml
mkdir shell
vi dshell.dart # paste contents of dshell.dart below
vi pubspec.yaml # paste contents of pubspec.yaml below
pub get
dart dshell.dart
```

dshell.dart

```dart
#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';

/// A toy REPL shell to replace your bash command line in just 50 lines of dart.
void main(List<String> args) {
  // Loop, asking for user input and evaluating it
  for (;;) {
    var line = ask('${green(basename(pwd))}${blue('>')}');
    if (line.isNotEmpty) {
      evaluate(line);
    }
  }
}

// Evaluate the users input
void evaluate(String command) {
  var parts = command.split(' ');
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
    find('*', root: pwd, recursive: false, types: [Find.file, Find.directory])
        .forEach((file) => print('  $file'));
  } else {
    for (var pattern in patterns) {
      find(pattern,
              root: pwd, recursive: false, types: [Find.file, Find.directory])
          .forEach((file) => print('  $file'));
    }
  }
}

```

The required pubspec.yaml

pubspec.yaml 

```yaml
name: dshell
dependencies: 
  dcli: ^0.32.0
```

