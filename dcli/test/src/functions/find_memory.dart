#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

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
