#! /usr/bin/env dcli

import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:args/args.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:dcli/src/pubspec/pubspec.dart';

///
/// Starts a docker shell with a full install
/// of the dcli tools
///
/// This is intended to allow you to work on scripts developed
/// with dcli.
///
/// If you are looking to work on dcli itself then use dev_dcli_cli.dart

Future<void> main(List<String> args) async {
  Settings().setVerbose(enabled: false);
  final cmds = CommandRunner<void>(
      'dcli_cli', 'Manage and run the dcli_cli docker container');
  cmds.addCommand(RunCommand());
  cmds.addCommand(BuildCommand());
  cmds.addCommand(PushCommand());

  try {
    await cmds.run(args);
  } on UsageException catch (e) {
    print(e.message);
    showUsage(cmds.argParser);
  }
}

void showUsage(ArgParser parser) {
  print(parser.usage);
  exit(1);
}

class RunCommand extends Command<void> {
  @override
  String get description =>
      'Starts the dcli_cli container and drops you into the cli';

  @override
  String get name => 'run';

  @override
  void run() {
    /// The volume will only be created if it doesn't already exist.
    'docker volume create dcli_scripts'
        .forEach(devNull, stderr: (line) => print(red(line)));
    const cmd =
        'docker run -v dcli_scripts:/home/scripts --network host -it dcli:dcli_cli /bin/bash';

    // print(cmd);
    cmd.run;
  }
}

class BuildCommand extends Command<void> {
  @override
  String get description => 'Builds the dcli_cli image';

  @override
  String get name => 'build';

  @override
  void run() {
    final pubspec = PubSpec.fromScript(Script.current);
    final version = pubspec.version.toString();
    // if (!argResults.wasParsed('version')) {
    //   printerr(red('You must pass a --version.'));
    //   showUsage(argParser);
    // }
    // var version = argResults['version'] as String;
    // mount the local dcli files from ..
    print('Building version: $version');
    'sudo docker build -f ./dcli_cli.df -t bsuttonnoojee/dcli_cli:$version .'
        .run;
  }
}

class PushCommand extends Command<void> {
  PushCommand() {
    argParser.addOption('version',
        help: 'The version no. to tag this image with');
  }
  @override
  String get description => 'Pushes the dcli_cli container to docker hub';

  @override
  String get name => 'push';

  @override
  void run() {
    // if (!argResults.wasParsed('version')) {
    //   printerr(red('You must pass a --version.'));
    //   showUsage(argParser);
    // }
    // var version = argResults['version'] as String;

    final pubspec = PubSpec.fromScript(Script.current);
    final version = pubspec.version.toString();
    print('Pushing version: $version');
    'sudo docker push bsuttonnoojee/dcli_cli:$version'.run;
  }
}
