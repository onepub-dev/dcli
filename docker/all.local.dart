#! /usr/bin/env dshell

import 'package:dshell/dshell.dart';
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
    // mount the local dshell files from ..
    print('about to docker build');
    'sudo docker build -f ./all.local.df -t dshell:all_local_test ..'.run;
  }

  print('about to docker run');
  'sudo docker run dshell:all_local_test'.run;
}
