#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

/// Used by unit tests as a cross platform version of cat
void main(List<String> args) {
  for (final arg in args) {
    if (!exists(arg)) {
      print('cat: $arg: No such file or directory');
    } else {
      cat(arg);
    }
  }
}
