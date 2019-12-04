import 'dart:convert';
import 'dart:io';

import 'package:dshell/settings.dart';

import '../util/log.dart';

import 'dshell_function.dart';
import 'echo.dart';

///
/// Reads a line of text from stdin with an optional prompt.
///
/// If the user immediately enters newline without
/// entering any text then an empty string will
/// be returned.
///
/// ```dart
/// String response = ask(prompt="Do you like me?");
/// ```
///
/// In most cases stdin is attached to the console
/// allow you to ask the user to input a value.
///
/// If [prompt] set then the prompt will be printed
/// to the console and the cursor placed immediately after the prompt.
String ask({String prompt}) => Ask().ask(prompt: prompt);

class Ask extends DShellFunction {
  ///
  /// Reads user input from stdin and returns it as a string.
  String ask({String prompt}) {
    if (Settings().debug_on) {
      Log.d("ask:  ${prompt}");
    }
    if (prompt != null) {
      echo(prompt + " ", newline: false);
    }
    var line = stdin.readLineSync(
        encoding: Encoding.getByName('utf-8'), retainNewlines: false);

    if (line == null) {
      line = "";
    }

    if (Settings().debug_on) {
      Log.d("ask:  result ${line}");
    }

    return line;
  }
}
