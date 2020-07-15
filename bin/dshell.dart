import 'dart:io';

import 'package:dshell/src/script/entry_point.dart';

void main(List<String> arguments) {
  DShell().run(arguments);
}

class DShell {
  void run(List<String> arguments) {
    var exitCode = EntryPoint().process(arguments);

    exit(exitCode);
  }
}
