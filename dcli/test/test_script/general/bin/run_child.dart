#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';

///
/// This script will '.run' a child script passed as
///  the first and only argument.
void main(List<String> args) {
  final script = args[0];

  if (Platform.isWindows) {
    if (script.endsWith('.dart')) {
      'dart $script'.run;
    } else {
      script.run;
    }
  } else {
    script.run;
  }
}
