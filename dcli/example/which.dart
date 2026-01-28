#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

/// which appname
/// @Throwing(ArgParserException)
/// @Throwing(ArgumentError)
/// @Throwing(UnsupportedError)
void main(List<String> args) {
  final parser = ArgParser()..addFlag('verbose', abbr: 'v', negatable: false);

  final results = parser.parse(args);

  final verbose = results['verbose'] as bool?;

  if (results.rest.length != 1) {
    print(red('You must pass the name of the executable to search for.'));
    print(green('Usage:'));
    print(green('   which ${parser.usage}<exe>'));
    exit(1);
  }

  final command = results.rest[0];

  for (final path in PATH) {
    if (verbose!) {
      print('Searching: ${canonicalize(path)}');
    }
    if (exists(join(path, command))) {
      print(red('Found at: ${canonicalize(join(path, command))}'));
    }
  }
}
