// ignore_for_file: deprecated_member_use
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:cli';
import 'dart:io';

void main() {
  print('parent hasTerminal=${stdin.hasTerminal}');

  print('run child.dart');
  // ignore: discarded_futures
  var process = waitFor<Process>(Process.start('dart', ['./child.dart'],
      mode: ProcessStartMode.inheritStdio));
  waitFor<int>(process.exitCode);

  print('run child exe');
  process = waitFor<Process>(
      // ignore: discarded_futures
      Process.start('child', [], mode: ProcessStartMode.inheritStdio));

  waitFor<int>(process.exitCode);
}
