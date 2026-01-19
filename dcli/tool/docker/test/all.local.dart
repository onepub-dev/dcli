#! /usr/bin/env dart
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

///
/// runs the unit tests using Dockerfile.local which pulls the code
/// from the local files system at ..
/// @Throwing(ArgParserException)
/// @Throwing(ArgumentError)

void main(List<String> args) {
  final parser = ArgParser()..addFlag('runOnly', abbr: 'r');

  final results = parser.parse(args);
  final runOnly = results['runOnly'] as bool;

  if (!runOnly) {
    // mount the local dcli files from ..
    print(green('About to build docker'));
    final root = DartProject.self.pathToProjectRoot;
    'sudo docker build -f tool/docker/test/all.local.df -t dcli:all_local_test .'
        .start(workingDirectory: root);
  }

  print(green('About to docker run'));

  'sudo docker run dcli:all_local_test'.run;
}
