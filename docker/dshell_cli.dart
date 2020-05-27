#! /usr/bin/env dshell
import 'package:dshell/dshell.dart';

///
/// Starts a docker shell from which you can do dshell development

void main(List<String> args) {
  Settings().setVerbose(enabled: false);
  var parser = ArgParser();
  parser.addFlag('runOnly', abbr: 'r', defaultsTo: false);

  var results = parser.parse(args);
  var runOnly = results['runOnly'] as bool;

  if (!runOnly) {
    // mount the local dshell files from ..
    'sudo docker build -f ./dshell_cli.df -t dshell:dshell_cli .'.run;
  }

  /// The volume will only be created if it doesn't already exist.
  'docker volume create dshell_scripts'
      .forEach(devNull, stderr: (line) => print(red(line)));
  var cmd =
      'docker run -v dshell_scripts:/home/scripts --network host -it dshell:dshell_cli /bin/bash';

  // print(cmd);
  cmd.run;
}
