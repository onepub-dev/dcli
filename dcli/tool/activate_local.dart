#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

/// globally activates dcli from a local path rather than a public package.
///
///
void main(List<String> args) {
  if (!Shell.current.isPrivilegedUser) {
    printerr(red(Shell.current.privilegesRequiredMessage('activate_local')));
    exit(1);
  }
  final root = DartProject.self.pathToProjectRoot;
  PubCache().globalActivateFromSource(root);
  'dcli install'.start();
  PubCache().globalActivateFromSource(root);
}
