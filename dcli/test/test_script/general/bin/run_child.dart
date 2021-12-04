#! /usr/bin/env dcli

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
