#! /usr/bin/env dcli

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

///
/// Starts a docker cli to facilitate development on
/// dcli in an isolated environment.
///
/// If you are looking to work on scripts that simply use
/// dcli then use dcli_cli.df

void main(List<String> args) {
  final parser = ArgParser()..addFlag('runOnly', abbr: 'r');

  final results = parser.parse(args);
  final runOnly = results['runOnly'] as bool;

  if (!runOnly) {
    // mount the local dcli files from ..
    'sudo docker build -f ./dev_dcli_cli.df -t dcli:dev_dcli_cli ..'.run;
  }

  'sudo docker run -it dcli:dev_dcli_cli /bin/bash'.run;
}
