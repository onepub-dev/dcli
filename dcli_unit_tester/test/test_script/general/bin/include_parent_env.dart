#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';

void main(List<String> args) {
  if (args.isNotEmpty && args[0] == 'child') {
    final value = Platform.environment['MY_VAR'] ?? '(not set)';
    print('Child sees MY_VAR: $value');
    return;
  }

  final mode = args.isEmpty ? 'startFromArgs' : args[0];

  // Remove the env var from DCli's env map; we only want to test inheritance.
  env['MY_VAR'] = null;

  Progress progress;
  if (mode == 'start') {
    final quotedExe = '"${Platform.resolvedExecutable}"';
    final quotedScript = '"${Platform.script.toFilePath()}"';
    progress = start(
      '$quotedExe $quotedScript child',
      progress: Progress.capture(),
      nothrow: true,
      includeParentEnvironment: false,
    );
  } else if (mode == 'startFromArgs') {
    progress = startFromArgs(
      Platform.resolvedExecutable,
      [Platform.script.toFilePath(), 'child'],
      progress: Progress.capture(),
      nothrow: true,
      includeParentEnvironment: false,
    );
  } else {
    stderr.writeln('Unknown mode: $mode');
    exit(64);
  }

  for (final line in progress.toList()) {
    stdout.writeln(line);
  }
}
