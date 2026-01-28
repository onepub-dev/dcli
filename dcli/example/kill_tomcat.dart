#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

void main() {
  // find all java processes
  var killed = false;
  'ps aux'.forEach((line) {
    if (line.contains('java') && line.contains('tomcat')) {
      final parts = line.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        final pidPart = parts[1];
        final pid = int.tryParse(pidPart) ?? -1;
        if (pid != -1) {
          print('Killing tomcat with pid=$pid');
          'kill -9 $pid'.run;
          killed = true;
        }
      }
    }
  });

  if (!killed) {
    print('tomcat process not found.');
  }
}
