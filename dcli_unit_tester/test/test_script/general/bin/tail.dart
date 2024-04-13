#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

/// Used by unit tests as a cross platform version of cat
void main(List<String> args) {
  final parser = ArgParser()..addOption('n', abbr: 'n', defaultsTo: '10');

  final results = parser.parse(args);

  final lines = int.tryParse(results['n'] as String);
  if (lines == null) {
    printerr("Argument passed to -n must ge an integer. Found ${results['n']}");
    exit(1);
  }

  final paths = results.rest;

  if (paths.isEmpty) {
    printerr('Expected at least one file');
    exit(1);
  }

  for (final path in paths) {
    if (Settings().isWindows) {
      final files = find(path, recursive: false).toList();
      if (files.isEmpty) {
        printerr(
            "head: cannot open '$path' for reading: No such file or directory");
        exit(1);
      } else {
        for (final file in files) {
          tail(file, lines);
        }
      }
    } else {
      if (!exists(path)) {
        printerr(
            "head: cannot open '$path' for reading: No such file or directory");
      } else {
        tail(path, lines);
      }
    }
  }
}
