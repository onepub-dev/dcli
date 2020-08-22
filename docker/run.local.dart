#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';
import 'package:args/args.dart';

///
/// Allows you to run a clean cli that runs dcli from the local
/// dcli source (located at ..)

void main(List<String> args) {
  var parser = ArgParser();
  parser.addCommand('build');

  var results = parser.parse(args);

  if (results.command != null) {
    if (results.command.name != 'build') {
      throw ArgumentError('The only supported command is "build"');
    }
    // mount the local dcli files from ..
    print('Starting build of docker image');
    'sudo docker build -f docker/run.local.df -t dcli:run_local .'.start(workingDirectory: '..');
  } else {
    /// runt the s
    'docker run -v $pwd:/home --network host -it dcli:run_local  /bin/bash'.run;
    // .start(workingDirectory: '..');
  }
}
