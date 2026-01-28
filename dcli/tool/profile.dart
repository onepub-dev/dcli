#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

/// Start up a dart script in debug/profile mode
///
/// @Throwing(RangeError)
void main(List<String> args) {
  if (args.isEmpty) {
    printerr(red('You must pass in a dart script and optional args to run.'));
    showUsage();
    exit(1);
  }

  final script = args[0];

  if (extension(script) != '.dart') {
    printerr(red('You must pass in a dart script name ending in .dart'
        ' as the first argument. Found $script'));
    showUsage();
    exit(1);
  }

  var scriptArgs = <String>[];
  if (args.length > 1) {
    scriptArgs = args.sublist(1);
  }
  print(green('Starting ${basename(script)} paused'));
  print(blue('Click the second link to open DevTools'));
  'dart run --pause-isolates-on-start --observe $script ${scriptArgs.join(' ')}'
      .run;
}

void showUsage() {
  print('Profile a dart script with DevTools');
  print(
      'profile.dart myscript.dart [--some --optional --args --to --your=app]');
}
