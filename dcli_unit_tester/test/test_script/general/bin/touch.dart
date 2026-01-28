#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

/// Used by unit tests as a cross platform version of touch
void main(List<String> args) {
  final parser = ArgParser();
  final results = parser.parse(args);

  final paths = results.rest;

  if (paths.isEmpty) {
    printerr('Expected at least one file');
    exit(1);
  }

  for (final path in paths) {
    if (Settings().isWindows) {
      final files = find(path, recursive: false).toList();
      if (files.isEmpty) {
        printerr("touch: cannot open '$path' "
            'for reading: No such file or directory');
        exit(1);
      } else {
        for (final file in files) {
          touch(file, create: true);
        }
      }
    } else {
      if (!exists(path)) {
        printerr("touch: cannot open '$path' for reading: "
            'No such file or directory');
      } else {
        touch(path, create: true);
      }
    }
  }
}
