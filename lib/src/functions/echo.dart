import 'dart:io';

import 'function.dart';
import '../util/waitForEx.dart';

/// Writes [text] to stdout including a newline.
///
/// ```dart
/// echo("Hello world", newline=false);
/// ```
///
/// If [newline] is false then a newline will not be output.
///
/// [newline] defaults to false.
void echo(String text, {bool newline = false}) => Echo().echo(text, newline);

class Echo extends DShellFunction {
  void echo(String text, bool newline) {
    if (newline) {
      stdout.writeln(text);
    } else {
      stdout.write(text);
    }
    waitForEx<dynamic>(stdout.flush());
  }
}
