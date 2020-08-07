#! /usr/bin/env dshell

import 'dart:io';

import 'package:dshell/dshell.dart';

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
  Settings().setVerbose(enabled: true);

  for (var path in paths) {
    if (Platform.isWindows) {
      var files = find(path).toList();
      if (files.isEmpty) {
        printerr(
            "head: cannot open '$path' for reading: No such file or directory");
        exit(1);
      } else {
        for (var file in files) {
          head(file, lines);
        }
      }
    } else {
      if (!exists(path)) {
        printerr(
            "head: cannot open '$path' for reading: No such file or directory");
      } else {
        head(path, lines);
      }
    }
  }
}
