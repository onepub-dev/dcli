#! /usr/bin/env dcli
// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:dmailhog/src/commands/config.dart';
import 'package:dmailhog/src/commands/install.dart';
import 'package:dmailhog/src/commands/run.dart';
import 'package:dmailhog/src/commands/view.dart';
import 'package:dmailhog/src/usage.dart';

void main(List<String> args) async {
  final runner = CommandRunner<void>('dmailhog', 'Installs and runs mail hog')
    ..addCommand(ConfigCommand())
    ..addCommand(InstallCommand())
    ..addCommand(RunCommand())
    ..addCommand(ViewCommand());

  runner.argParser.addFlag('debug',
      abbr: 'd', help: 'Output verbose debugging information');

  try {
    await runner.run(args);
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    showException(runner, e);
  }
}
