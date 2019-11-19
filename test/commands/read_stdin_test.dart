import 'dart:io';

import 'package:test/test.dart' as t;
import "package:dshell/dshell.dart";

void main() {
  Settings().debug_on = true;

  // can't be run from within vscode as it needs console input.
  t.group("Read from stdin", () {
    t.test("Read and then write ", () {
      readStdin().forEach((line) => print(stdout));
    }, skip: true);
  });
}
