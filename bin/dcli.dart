// @dart=2.9
// TODO: remove the above when we get past mix-mode.

import 'dart:io';

import 'package:dcli/src/script/entry_point.dart';

void main(List<String> arguments) {
  DCli().run(arguments);
}

class DCli {
  void run(List<String> arguments) {
    final exitCode = EntryPoint().process(arguments);

    exit(exitCode);
  }
}
