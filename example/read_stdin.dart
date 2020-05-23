import 'package:dshell/dshell.dart';

///
/// Demonstrates reading from stdin and writing to stdout.
//
void main() {
  readStdin().forEach(print);
}
