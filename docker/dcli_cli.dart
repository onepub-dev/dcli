#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

///
/// Starts a docker shell with a full install
/// of the dcli tools
/// 
/// This is intended to allow you to work on scripts developed
/// with dcli.
/// 
/// If you are looking to work on dcli itself then use dev_dcli_cli.dart

void main(List<String> args) {
  Settings().setVerbose(enabled: false);
  var parser = ArgParser();
  parser.addFlag('runOnly', abbr: 'r', defaultsTo: false);

  var results = parser.parse(args);
  var runOnly = results['runOnly'] as bool;

  if (!runOnly) {
    // mount the local dcli files from ..
    'sudo docker build -f ./dcli_cli.df -t dcli:dcli_cli .'.run;
  }

  /// The volume will only be created if it doesn't already exist.
  'docker volume create dcli_scripts'.forEach(devNull, stderr: (line) => print(red(line)));
  var cmd = 'docker run -v dcli_scripts:/home/scripts --network host -it dcli:dcli_cli /bin/bash';

  // print(cmd);
  cmd.run;
}
