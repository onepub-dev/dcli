/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:convert';

import 'package:dcli/dcli.dart';

Future<void> main(List<String> args) async {
  final ls = 'ls'.process;
  final head = 'head'.process;
  final headStream = head.stream;
  // stdout.addStream(head.stream);

  final sink = await head.sink;

  ls.stream
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map((line) {
        print(line);
        return '1: line';
      })
      .transform(utf8.encoder)
      .listen((line) => sink.add(line), onDone: () {});

  headStream
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen(print, onDone: () {
    sink.close();
  });

  print('post ils');
}
