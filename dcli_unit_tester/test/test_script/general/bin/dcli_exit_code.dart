#! /usr/bin/env dart
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:strings/strings.dart';

/// Runs for 1 second and exits with the exit code passed as the first argument.
void main(List<String> args) {
  sleep(1);
  exitCode = int.parse(Strings.orElseOnBlank(args[0], '0'));
}
