import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/util/runnable_process.dart';

///
/// Demonstrates reading from stdin and writing to stdout.
//
void main() {
  readStdin().forEach(console);
}
