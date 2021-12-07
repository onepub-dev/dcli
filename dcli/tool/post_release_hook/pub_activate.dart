#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

/// Activate the latest version of dcli as part of the publishing the package.
void main(List<String> args) {
  'dart pub global activate dcli'.run;
}
