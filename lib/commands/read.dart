import 'dart:convert';
import 'dart:io';

import '../util/log.dart';

import 'command.dart';
import 'settings.dart';

///
/// Reads a line of text from stdin.
///
/// If the user immediately enters newline without
/// entering any text then an empty string will
/// be returned.
///
/// In most cases stdin is attached to the console
/// allow you to ask the user to input a value.
///
/// If [prompt] set then the prompt will be printed
/// to the console and the cursor placed immediately after the prompt.
String read({String prompt}) => Read().read(prompt: prompt);

class Read extends Command {
  ///
  /// Reads user input from stdin and returns it as a string.
  String read({String prompt}) {
    if (Settings().debug_on) {
      Log.d("read:  ${prompt}");
    }
    if (prompt != null) {
      print(prompt);
    }
    var line = stdin.readLineSync(
        encoding: Encoding.getByName('utf-8'), retainNewlines: false);

    if (line == null) {
      line = "";
    }

    if (Settings().debug_on) {
      Log.d("read:  result ${line}");
    }

    return line;
  }
}
