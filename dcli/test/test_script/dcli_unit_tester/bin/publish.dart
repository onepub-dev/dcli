#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

/// Dart no longer allows you to publish a nested package so
/// use this command to publish dcli_unit_tester to pub.dev.
void main() {
  withTempDir((tmp) {
    copyTree('.', tmp);
    'dart pub publish --force'.start(workingDirectory: tmp, nothrow: true);
  });
}
