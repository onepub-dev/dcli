#! /usr/bin/env dart
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli/src/version/version.g.dart';

/// Activate the latest version of dcli as part of the publishing the package.
void main(List<String> args) {
  /// we pass the version so that we can activate pre-relase version
  /// (e.g. -beta.1) which the activate command will usually ignore.
  'dart pub global activate dcli_sdk $packageVersion'.run;
}
