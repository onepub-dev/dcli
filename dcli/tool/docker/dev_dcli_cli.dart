#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */




import 'package:args/args.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

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
    final dockerFilePath =
        join(DartProject.self.pathToToolDir, 'docker', 'dev_dcli_cli.df');
    // mount the local dcli files from ..
    'sudo docker build -f $dockerFilePath -t dcli:dev_dcli_cli .'.run;
  }

  'sudo docker run -it dcli:dev_dcli_cli /bin/bash'.run;
}
