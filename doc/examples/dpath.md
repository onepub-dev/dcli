# dpath

Prints and validates that each path PATH exists.

```dart
 ./dpath.dart 
Test:  ✔ /usr/local/sbin
Test:  ✔ /usr/local/bin
Test:  ✔ /usr/sbin
Test:  ✔ /usr/bin
Test:  ✔ /sbin
Test:  ✔ /bin
Test:  ✔ /usr/games
Test:  ✔ /usr/local/games
Test:  ✔ /snap/bin
Test:  ✔ /usr/lib/dart/bin
Test:  ✔ /usr/lib/dart/bin
```

```dart
#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';
import 'package:args/args.dart';

/// dpath appname
/// print the systems PATH variable contents and validates each path.

const String tick = '''\xE2\x9C\x93''';

const String posixTick = '''\u2714''';

const String cross = 'x';

void main(List<String> args) {
  var parser = ArgParser();
  parser..addFlag('verbose', abbr: 'v', defaultsTo: false, negatable: false);

  for (var path in PATH) {
    var pathexists = exists(path);

    if (pathexists == true) {
      print('Test:  $posixTick ${canonicalize(path)}');
    } else {
      print(red('Test: $cross ${canonicalize(path)}'));
    }
  }
}

```

