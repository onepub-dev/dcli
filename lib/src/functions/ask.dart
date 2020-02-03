import 'dart:convert';
import 'dart:io';

import 'package:dshell/src/util/waitForEx.dart';

import '../settings.dart';

import '../util/log.dart';
import '../util/string_as_process.dart';

import 'dshell_function.dart';
import 'echo.dart';
import 'env.dart';

///
/// Reads a line of text from stdin with an optional prompt.
///
/// If the user immediately enters newline without
/// entering any text then an empty string will
/// be returned.
///
/// ```dart
/// String response = ask(prompt:"Do you like me?");
/// ```
///
/// In most cases stdin is attached to the console
/// allow you to ask the user to input a value.
///
/// If [prompt] is set then the prompt will be printed
/// to the console and the cursor placed immediately after the prompt.
///
/// if [toLower] is true then the returned result is converted to lower case.
/// This can be useful if you need to compare the entered value.
///
/// If [hidden] is true then the entered values will not be echoed to the
/// console, instead '*' will be displayed. This is uesful for capturing
/// passwords.
/// NOTE: if there is no terminal detected then this will fallback to
/// a standard ask input in which case the hidden characters WILL BE DISPLAYED
/// as they are typed.
///
/// TODO: work out why we aren't detecting a terminal when running under
/// dshell (and I assume the sh created by the #! env setting)
///
String ask({String prompt, bool toLower = false, bool hidden = false}) =>
    Ask().ask(prompt: prompt, toLower: toLower, hidden: hidden);

/// [confirm] is a specialized version of ask that returns true or
/// false based on the value entered.
/// Accepted values are y|t|true|yes and n|f|false|no (case insenstiive).
/// If the user enters an unknown value an error is printed
/// and they are reprompted.
bool confirm({String prompt}) {
  bool result;
  var matched = false;
  while (!matched) {
    var entered = Ask().ask(prompt: prompt, toLower: true, hidden: false);
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
  String ask({String prompt, bool toLower, bool hidden}) {
    if (Settings().debug_on) {
      Log.d('ask:  ${prompt}');
    }
    if (prompt != null) {
      echo(prompt + ' ', newline: false);
    }

    String line;
    if (hidden == true && stdin.hasTerminal) {
      line = readHidden();
    } else {
      line = stdin.readLineSync(
          encoding: Encoding.getByName('utf-8'), retainNewlines: false);
    }

    line ??= '';

    if (toLower == true) {
      line = line.toLowerCase();
    }

    if (Settings().debug_on) {
      Log.d('ask:  result ${line}');
    }

    return line;
  }

  String readHidden() {
    var value = <int>[];

    try {
      stdin.echoMode = false;
      stdin.lineMode = false;
      int char;
      do {
        char = stdin.readByteSync();
        if (char != 10) {
          stdout.write('*');
          // we must wait for flush as only one flush can be outstanding at a time.
          waitForEx<void>(stdout.flush());
          value.add(char);
        }
      } while (char != 10);
    } finally {
      stdin.echoMode = true;
      stdin.lineMode = true;
    }

    // output a newline as we have suppressed it.
    print('');

    // return the entered value as a String.
    return Encoding.getByName('utf-8').decode(value);
  }
}
