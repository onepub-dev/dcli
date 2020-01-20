import 'dart:convert';
import 'dart:io';

import '../settings.dart';

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
///
/// if [multiline] is true then
String ask({String prompt}) => Ask().ask(prompt: prompt);

/// [yesNo] is a specialized version of ask that returns true or
/// false based on the value entered.
/// Accepted values are y|t|true|yes and n|f|false|no.
/// Entered values are forced to lower case.
/// If the user enteres an unknown value an error is printed
/// and they are reprompted.
bool confirm({String prompt}) {
  bool result;
  var matched = false;
  while (!matched) {
    var entered = Ask().ask(prompt: prompt, toLower: true);
    var lower = entered.toLowerCase();

    if (['y', 't', 'true', 'yes'].contains(lower)) {
      result = true;
      matched = true;
      break;
    }
    if (['n', 'f', 'false', 'no'].contains(lower)) {
      result = false;
      matched = true;
      break;
    }
    print('Invalid value: $entered');
  }
  return result;
}

class Ask extends DShellFunction {
  ///
  /// Reads user input from stdin and returns it as a string.
  String ask({String prompt, bool toLower}) {
    if (Settings().debug_on) {
      Log.d('ask:  ${prompt}');
    }
    if (prompt != null) {
      echo(prompt + ' ', newline: false);
    }
    var line = stdin.readLineSync(
        encoding: Encoding.getByName('utf-8'), retainNewlines: false);

    line ??= '';

    if (Settings().debug_on) {
      Log.d('ask:  result ${line}');
    }

    return line;
  }
}
