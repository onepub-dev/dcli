#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

/// Used by unit tests as a cross platform version of touch
void main(List<String> args) {
  var parser = ArgParser();
  var results = parser.parse(args);

  var paths = results.rest;

  if (paths.isEmpty) {
    printerr('Expected at least one file');
    exit(1);
  }
  Settings().setVerbose(enabled: true);

  for (var path in paths) {
    if (Platform.isWindows) {
      var files = find(path).toList();
      if (files.isEmpty) {
        printerr(
            "touch: cannot open '$path' for reading: No such file or directory");
        exit(1);
      } else {
        for (var file in files) {
          touch(file, create: true);
        }
      }
    } else {
      if (!exists(path)) {
        printerr(
            "touch: cannot open '$path' for reading: No such file or directory");
      } else {
        touch(path, create: true);
      }
    }
  }
}
