#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

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
    'dcli_cli',
    'Manage and run the dcli_cli docker container',
  )
    ..addCommand(RunCommand())
    ..addCommand(BuildCommand())
    ..addCommand(PushCommand());

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

const imageName = 'onepub-dev/dcli_cli';

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

    final pubspec = PubSpec.fromFile(DartProject.self.pathToPubSpec);
    final version = pubspec.version.toString();

    'docker run -v dcli_scripts:/home/scripts --network host -it $imageName:$version /bin/bash'
        .run;
  }
}

class BuildCommand extends Command<void> {
  BuildCommand() {
    argParser.addFlag('clean', help: 'force a clean build');
  }
  @override
  String get description => 'Builds the dcli_cli image';

  @override
  String get name => 'build';

  @override
  void run() {
    final pubspec = PubSpec.fromFile(DartProject.self.pathToPubSpec);
    final version = pubspec.version.toString();
    final projectRoot = DartProject.self.pathToProjectRoot;

    final pathToDockerFile = join(projectRoot, 'tool', 'docker', 'dcli_cli.df');
    // if (!argResults.wasParsed('version')) {
    //   printerr(red('You must pass a --version.'));
    //   showUsage(argParser);
    // }
    // var version = argResults['version'] as String;
    // mount the local dcli files from ..
    final clean = argResults!['clean'] as bool;
    print('Building version: $version');
    'sudo docker build  ${clean == true ? '--no-cache' : ''} '
            '-f $pathToDockerFile -t $imageName:$version .'
        .run;
  }
}

class PushCommand extends Command<void> {
  PushCommand() {
    argParser.addOption(
      'version',
      help: 'The version no. to tag this image with',
    );
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

    final pubspec = PubSpec.fromFile(DartProject.self.pathToPubSpec);
    final version = pubspec.version.toString();
    print('Pushing version: $version');
    'sudo docker push $imageName:$version'.run;
  }
}
