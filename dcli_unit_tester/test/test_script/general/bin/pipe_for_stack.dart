/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final ls = await start('ls', []);
  final head = await start('head', ['-n', '5']);

  var cnt = 1;
  await ls.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map((line) {
        print(line);
        return '${cnt++}: $line';
      })
      .transform(utf8.encoder)
      .pipe(head.stdin);

  //await head.stdout.transform(streamTransformer).pipe(stdout);
}

Future<Process> start(String command, List<String> args) {
  final process = Process.start(
    command,
    args,
  );
  return process;
}
