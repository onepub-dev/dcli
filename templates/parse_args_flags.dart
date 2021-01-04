#! /usr/bin/env dcli

/// remove the next line
/// ignore_for_file: unused_import

// ignore: import_of_legacy_library_into_null_safe
import 'package:args/args.dart';

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
