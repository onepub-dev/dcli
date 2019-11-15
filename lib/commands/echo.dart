import 'dart:cli';
import 'dart:io';

import 'package:dshell/commands/command.dart';

/// Writes [text] to stdout including a newline.
///
/// If [newline] is false then a newline will not be output.
///
/// [newline] defaults to false.
void echo(String text, {bool newline = false}) => Echo().echo(text);

class Echo extends Command {
  void echo(String text, {bool newline = false}) {
    if (newline) {
      stdout.writeln(text);
    } else {
      stdout.write(text);
    }
    var future = stdout.flush();
    waitFor<dynamic>(future);
  }
}
