#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

import 'package:args/args.dart';

///
/// runs the unit tests using Dockerfile.local which pulls the code
/// from the local files system at ..

void main(List<String> args) {
  final parser = ArgParser()..addFlag('runOnly', abbr: 'r');

  final results = parser.parse(args);
  final runOnly = results['runOnly'] as bool;

  if (!runOnly) {
    // mount the local dcli files from ..
    print(green('About to build docker'));
    final root = DartProject.current.pathToProjectRoot;
    'sudo docker build -f tool/docker/test/all.local.df -t dcli:all_local_test .'
        .start(workingDirectory: root);
  }

  print(green('About to docker run'));

  'sudo docker run dcli:all_local_test'.run;
}
