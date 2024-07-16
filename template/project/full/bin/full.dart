#! /usr/bin/env dart

import 'package:args/command_runner.dart';
import 'package:full/src/args/usage.dart';
import 'package:full/src/commands/config.dart';
import 'package:full/src/commands/install.dart';
import 'package:full/src/commands/run.dart';
import 'package:full/src/commands/view.dart';

void main(List<String> args) async {
  // add set of supported commands
  final runner = CommandRunner<void>('dmailhog', 'Installs and runs mail hog')
    ..addCommand(ConfigCommand())
    ..addCommand(InstallCommand())
    ..addCommand(RunCommand())
    ..addCommand(ViewCommand());

  /// Add global options available to all commands
  /// NOTE: update args/global_args.dart to parse any flags/options
  /// you add here.
  runner.argParser.addFlag('debug',
      abbr: 'd',
      help: 'Output verbose debugging information',
      negatable: false);

  try {
    // parse the cli options passed and run the selected command.
    await runner.run(args);
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    showException(runner, e);
  }
}
