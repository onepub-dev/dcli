#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

/// Used by unit tests as a cross platform version of cat
void main(List<String> args) {
  var parser = ArgParser();
  parser.addOption('n', abbr: 'n', defaultsTo: '10');

  var results = parser.parse(args);

  var lines = int.tryParse(results['n'] as String);
  if (lines == null) {
    printerr("Argument passed to -n must ge an integer. Found ${results['n']}");
    exit(1);
  }

  var paths = results.rest;

  if (paths.isEmpty) {
    printerr('Expected at least one file');
    exit(1);
  }

  for (var path in paths) {
    if (Settings().isWindows) {
      var files = find(path, recursive: false).toList();
      if (files.isEmpty) {
        printerr("head: cannot open '$path' for reading: No such file or directory");
        exit(1);
      } else {
        for (var file in files) {
          tail(file, lines);
        }
      }
    } else {
      if (!exists(path)) {
        printerr("head: cannot open '$path' for reading: No such file or directory");
      } else {
        tail(path, lines);
      }
    }
  }
}
