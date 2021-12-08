#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

void main() {
  var count = 0;
  find(
    '*',
    workingDirectory: '/',
    types: <FileSystemEntityType>[Find.directory, Find.file],
    includeHidden: true,
  ).forEach((file) {
    count++;
    print('actioned $count');
    if (count % 1000 == 0) {
      print(count);
    }
  });
}
