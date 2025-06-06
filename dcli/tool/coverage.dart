#! /usr/bin/env dart
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

/// dcli script generated by:
/// dcli create coverage.dart
///
/// See
/// https://pub.dev/packages/dcli#-installing-tab-
///
/// For details on installing dcli.
///

void main() {
  print('Hello World');

  '${DartSdk().pathToDartExe} pub global run coverage:collect_coverage --out=coverage/coverage.json --resume-isolates --wait-paused'
      .start(detached: true, extensionSearch: false);

  '${DartSdk().pathToDartExe} --observe test/.test_coverage.dart'.run;

  '${DartSdk().pathToDartExe} pub global run coverage:format_coverage --packages=${DartSdk().pathToPackageConfig} --in=coverage/coverage.json --lcov --report-on=lib --out=coverage/lcov.info'
      .run;
}
