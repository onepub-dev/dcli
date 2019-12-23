
import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/runnable_process.dart';

///
/// Demonstrates reading from stdin and writing to stdout.
//
void main() {
  readStdin().forEach(console);
}
