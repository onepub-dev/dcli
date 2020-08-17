#! /usr/bin/env dshell
// remove the next line
// ignore_for_file: unused_import
/*
@pubspec
name: find.dart
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
/// dshell find.dart -v --root . ---recursive --pattern *.*
///
/// to see the usage run:
///
/// dshell find.dart
///
/// Find all files that match the given pattern.
/// Starts from the current directory unless [--root]
/// is provided.
void main(List<String> args) {
  var parser = ArgParser();

  parser
    ..addFlag('verbose', abbr: 'v', defaultsTo: false)
    ..addFlag('recursive', abbr: 'r', defaultsTo: true)
    ..addOption('root',
        defaultsTo: '.',
        help: 'Specifies the directory to start searching from')
    ..addOption('pattern',
        abbr: 'p',
        help:
            'The search pattern to apply. e.g. *.txt. You need to quote the pattern to stop bash expanding it into a file list.');

  var results = parser.parse(args);

  var pattern = results['pattern'] as String;
  var root = results['root'] as String;
  var verbose = results['verbose'] as bool;
  var recursive = results['recursive'] as bool;

  if (pattern == null) {
    parser.usage;
    exit(-1);
  }

  if (verbose) {
    print('Verbose is on, starting find');
  }

  find(pattern, root: root, recursive: recursive).forEach(print);

  if (verbose) {
    print('Verbose is on, completed find');
  }
}
