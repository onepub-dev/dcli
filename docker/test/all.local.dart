#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';
import 'package:args/args.dart';

///
/// runs the unit tests using Dockerfile.local which pulls the code
/// from the local files system at ..

void main(List<String> args) {
  var parser = ArgParser();
  parser.addFlag('runOnly', abbr: 'r', defaultsTo: false);

  var results = parser.parse(args);
  var runOnly = results['runOnly'] as bool;

  if (!runOnly) {
    // mount the local dcli files from ..
    print('about to docker build');
    var root = Script.current.pathToProjectRoot;
    'sudo docker build -f ./all.local.df -t dcli:all_local_test .'
        .start(workingDirectory: root);
  }

  print('about to docker run');
  'sudo docker run dcli:all_local_test'.run;
}
