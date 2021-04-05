#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

import 'package:args/args.dart';

/// Used by unit tests as a cross platform version of touch
void main(List<String> args) {
  final parser = ArgParser();
  final results = parser.parse(args);

  final paths = results.rest;

  if (paths.isEmpty) {
    printerr('Expected at least one file');
    exit(1);
  }
  Settings().setVerbose(enabled: true);

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
