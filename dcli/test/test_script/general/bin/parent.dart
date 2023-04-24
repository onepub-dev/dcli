// ignore_for_file: deprecated_member_use
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

void main() async {
  print('parent hasTerminal=${stdin.hasTerminal}');

  print('run child.dart');
  var process = await Process.start('dart', ['./child.dart'],
      mode: ProcessStartMode.inheritStdio);
  await process.exitCode;

  print('run child exe');
  process =
      await Process.start('child', [], mode: ProcessStartMode.inheritStdio);
  await process.exitCode;
}
