#! /usr/bin/env dart
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

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
