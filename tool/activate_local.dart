#! /usr/bin/env dshell
import 'dart:io';

import 'package:dshell/dshell.dart';

/// globally activates dshell from a local path rather than a public package.
///
/// defaults to activation from ~/git/dshell
///
/// You can change the path by passing in:
/// activate_local path=<your path>
///
void main(List<String> args) {
  var parser = ArgParser();

  parser.addCommand('help');

  var path = join(HOME, 'git', 'dshell');

  parser.addOption('path', defaultsTo: path);

  var result = parser.parse(args);

  if (result.command != null) {
    print(
        '''globally activates dshell from a local path rather than a public package.

defaults to activation from ~/git/dshell

You can change the path by passing in:
activate_local --path=<your path>

Options:
${parser.usage}
''');
    exit(0);
  }

  path = result['path'] as String;

  'pub global activate --source path $path'.run;
}
