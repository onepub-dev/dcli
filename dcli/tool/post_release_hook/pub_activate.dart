#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io' as io;

import 'package:dcli/dcli.dart';
import 'package:dcli/src/version/version.g.dart';

/// Activate the latest version of dcli as part of the publishing the package.
void main(List<String> args) {
  if (args.contains('--dry-run') || args.contains('-n')) {
    print('post_release_hook: dry-run detected, skipping pub activation.');
    return;
  }

  /// we pass the version so that we can activate pre-relase version
  /// (e.g. -beta.1) which the activate command will usually ignore.
  var exitCode = 1;
  for (var attempt = 1; attempt <= 12; attempt++) {
    final progress = 'dart pub global activate dcli_sdk $packageVersion'.start(
      nothrow: true,
      progress: Progress.print(),
    );
    exitCode = progress.exitCode ?? 1;
    if (exitCode == 0) {
      return;
    }

    if (attempt < 12) {
      print(
        'dcli_sdk $packageVersion is not visible yet. '
        'Retrying in 30 seconds ($attempt/12).',
      );
      io.sleep(const Duration(seconds: 30));
    }
  }

  io.exit(exitCode);
}
