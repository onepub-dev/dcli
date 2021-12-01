#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

/// globally activates dcli from a local path rather than a public package.
///
///
void main(List<String> args) {
  final root = DartProject.self.pathToProjectRoot;
  DartProject.globalActivateFromSource(dirname(root));
  'dcli install'.start();
  DartProject.globalActivateFromSource(dirname(root));
}
