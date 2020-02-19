#! /usr/bin/env dshell
import 'package:dshell/dshell.dart';

///
/// Starts a docker shell from which you can do dshell development

void main(List<String> args) {
  var parser = ArgParser();
  parser.addFlag('runOnly', abbr: 'r', defaultsTo: false);

  var results = parser.parse(args);
  var runOnly = results['runOnly'] as bool;

  if (!runOnly) {
    // mount the local dshell files from ..
    'sudo docker build -f ./dshell_cli.df -t dshell:dshell_cli .'.run;
  }

  // 'sudo docker run dshell:docker_dev_cli -i -t bash -c'.run;
  // -v ~:/home maps the users entire home directory into docker.
  // 'docker run --network host  -v $HOME:/mnt/ -it  dshell:docker_dev_cli /bin/bash'
  //     .run;

  // var cmd = 'docker run --network host  --mount src="$HOME", dst=/me, type=bind -it  dshell:docker_dev_cli /bin/bash';
  var cmd =
      'docker run  --volume $HOME:/home --network host   -it dshell:dshell_cli      /bin/bash';

  print(cmd);
  cmd.run;
}
