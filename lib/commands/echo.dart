import 'dart:io';

import 'package:dshell/commands/command.dart';
import 'package:dshell/util/waitForEx.dart';

/// Writes [text] to stdout including a newline.
///
/// ```dart
/// echo("Hello world", newline=false);
/// ```
///
/// If [newline] is false then a newline will not be output.
///
/// [newline] defaults to false.
void echo(String text, {bool newline = false}) => Echo().echo(text);

class Echo extends Command {
  void echo(String text, {bool newline = true}) {
    if (newline) {
      stdout.writeln(text);
    } else {
      stdout.write(text);
    }
    var future = stdout.flush();
    waitForEx<dynamic>(future);
  }
}
