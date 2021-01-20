#! /usr/bin/env dcli
// remove the next line
// ignore_for_file: unused_import
/*
@pubspec
name: find.dart
dependencies:
  dcli: ^0.20.0
  args: ^1.5.2
  path: ^1.6.4
*/

import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;
import 'package:args/args.dart';

///
/// Call this program using:
/// dcli find.dart -v --workingDirectory . ---recursive --pattern *.*
///
/// to see the usage run:
///
/// dcli find.dart
///
/// Find all files that match the given pattern.
/// Starts from the current directory unless [--workingDirectory]
/// is provided.
void main(List<String> args) {
  final parser = ArgParser();

  parser
    ..addFlag('verbose', abbr: 'v')
    ..addFlag('recursive', abbr: 'r', defaultsTo: true)
    ..addOption('workingDirectory',
        defaultsTo: '.',
        help: 'Specifies the directory to start searching from')
    ..addOption('pattern',
        abbr: 'p',
        help:
            'The search pattern to apply. e.g. *.txt. You need to quote the pattern to stop bash expanding it into a file list.');

  final results = parser.parse(args);

  final pattern = results['pattern'] as String;
  final workingDirectory = results['workingDirectory'] as String;
  final verbose = results['verbose'] as bool;
  final recursive = results['recursive'] as bool;

  if (pattern == null) {
    parser.usage;
    exit(-1);
  }

  if (verbose) {
    print('Verbose is on, starting find');
  }

  find(pattern, workingDirectory: workingDirectory, recursive: recursive).forEach(print);

  if (verbose) {
    print('Verbose is on, completed find');
  }
}
