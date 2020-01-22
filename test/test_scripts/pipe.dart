import 'dart:convert';

import 'package:dshell/dshell.dart';

void main(List<String> args) {
  var ls = 'ls'.process;
  var head = 'head'.process;
  var headStream = head.stream;
  // stdout.addStream(head.stream);

  ls.stream
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map((line) {
        print(line);
        return '1: line';
      })
      .transform(utf8.encoder)
      .listen((line) => head.sink.add(line), onDone: () {});

  headStream
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) => print(line), onDone: () {
    head.sink.close();
  });

  print('post ils');
}
