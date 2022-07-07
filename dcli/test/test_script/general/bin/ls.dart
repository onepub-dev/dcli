#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

/// Used by unit tests as a cross platform version of ls.
void main(List<String> args) {
  if (Settings().isWindows) {
    for (final arg in args) {
      //  on windows powershell does not do glob expansion
      final files = find(arg, recursive: false).toList();
      if (files.isEmpty) {
        print("ls: cannot access '$arg': No such file or directory");
      } else {
        files.forEach(print);
      }
    }
  } else {
    // for linux/mac dcli will have expanded globs to file names
    for (final arg in args) {
      if (!exists(arg)) {
        print("ls: cannot access '$arg': No such file or directory");
      } else {
        print(arg);
      }
    }
  }
}
