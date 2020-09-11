#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

///
/// running unit tests from vs-code doesn't seem to work as it spawns
/// two isolates and runs tests in parallel (even when using the -j1 option)
/// Given we are actively modifying the file system this is a bad idea.
/// So this script forces the test to run serially via the -j1 option.
///
void main() {
  var root = Script.current.pathToProjectRoot;

  print(orange('cleaning old test and build artifacts'));
  if (exists('/tmp/dcli')) deleteDir('/tmp/dcli', recursive: true);

  /// Start by cleaning out any old build artifacts
  find('.packages', root: root, recursive: true)
      .forEach((file) => delete(file));
  find('.dart_tool', root: root, recursive: true)
      .forEach((file) => deleteDir(file, recursive: true));
  find('pubspec.lock', root: root, recursive: true)
      .forEach((file) => delete(file));

  '${DartSdk().pathToPubExe} run test -j1 --coverage ${join(root, 'coverage')}'
      .start(nothrow: true, workingDirectory: root);

  // cleanup temp
  if (exists('/tmp/dcli')) deleteDir('/tmp/dcli', recursive: true);
}
