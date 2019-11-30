#! /usr/bin/env dshell

/// remove the next line
/// ignore_for_file: unused_import

/*
@pubspec.yaml
name: hello_world.dart
dependencies:
  dshell: ^1.0.0
  args: ^1.5.2
  path: ^1.6.4
*/

import 'dart:io';
import 'package:dshell/dshell.dart';
import 'package:path/path.dart' as p;
import 'package:args/args.dart';

///
/// Call this program using:
/// dshell parse_args_flags.dart -v --name test and some more args
///
void main(List<String> args) {
  ArgParser parser = ArgParser();

  parser
    ..addFlag('verbose', abbr: 'v')
    ..addOption('name', abbr: 'n');

  ArgResults results = parser.parse(args);

  print(results['verbose']);
  print(results['name']);

  // print remaining cmd line args.
  print(results.rest);

  print(parser.usage);
}
