#! /usr/bin/env dcli
/*
@pubspec
name: which.dart
dependencies:
  dcli: ^1.0.0
*/

import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;
import 'package:args/args.dart';

/// which appname
void main(List<String> args) {
  var parser = ArgParser();
  parser..addFlag('verbose', abbr: 'v', defaultsTo: false, negatable: false);

  var results = parser.parse(args);

  var verbose = results['verbose'] as bool;

  if (results.rest.length != 1) {
    print(red('You must pass the name of the executable to search for.'));
    print(green('Usage:'));
    print(green('   which ${parser.usage}<exe>'));
    exit(1);
  }

  var command = results.rest[0];
  var home = env('HOME');

  List<String> paths;
  paths = env('PATH').split(':');

  for (var path in paths) {
    if (path.startsWith('~')) {
      path = path.replaceAll('~', home);
    }
    if (verbose) {
      print('Searching: ${p.canonicalize(path)}');
    }
    if (exists(p.join(path, command))) {
      print(red('Found at: ${p.canonicalize(p.join(path, command))}'));
    }
  }
}
