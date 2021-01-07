#! /usr/bin/env dcli

/// remove the next line
/// ignore_for_file: unused_import

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

///
/// Call this program using:
/// dcli parse_args_flags.dart -v --name test and some more args
///
void main(List<String> args) {
  final parser = ArgParser();

  parser
    ..addFlag('verbose', abbr: 'v')
    ..addOption('name', abbr: 'n');

  final results = parser.parse(args);

  print(results['verbose']);
  print(results['name']);

  // print remaining cmd line args.
  print(results.rest);

  print(parser.usage);
}
