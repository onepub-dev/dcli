#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

///
/// running unit tests from vs-code doesn't seem to work as it spawns
/// two isolates and runs tests in parallel (even when using the -j1 option)
/// Given we are actively modifying the file system this is a bad idea.
/// So this script forces the test to run serially via the -j1 option.
///
void main(List<String> args) {
  print(orange('cleaning test artifacts'));

  if (exists('/tmp/dcli')) {
    print('Deleting old test runs. This can take a while.');
    deleteDir('/tmp/dcli');
  }
}
