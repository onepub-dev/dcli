/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
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

Future<Process> start(String command, List<String> args) async {
  final process = Process.start(
    command,
    args,
  );
  return process;
}
