#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

/// Used by unit tests as a cross platform version of ls.
void main(List<String> args) {
  if (Settings().isWindows) {
    for (var arg in args) {
      //  on windows powershell does not do glob expansion
      var files = find(arg, recursive: false).toList();
      if (files.isEmpty) {
        print("ls: cannot access '$arg': No such file or directory");
      } else {
        for (var file in files) {
          print(file);
        }
      }
    }
  } else {
    // for linux/mac dcli will have expanded globs to file names
    for (var arg in args) {
      if (!exists(arg)) {
        print("ls: cannot access '$arg': No such file or directory");
      } else {
        print(arg);
      }
    }
  }
}
