#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

/// globally activates dcli from a local path rather than a public package.
///
///
void main(List<String> args) {
  print('hi');
  if (!Shell.current.isPrivilegedUser) {
    printerr(red(Shell.current.privilegesRequiredMessage('activate_local')));
    exit(1);
  }
  final root = DartProject.self.pathToProjectRoot;
  print(root);
  PubCache().globalActivateFromSource(root);
  'dcli install'.start();
  PubCache().globalActivateFromSource(root);
}
