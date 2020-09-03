import 'dart:convert';
import 'dart:io';

import 'package:validators/validators.dart';

import '../../dcli.dart';
import '../settings.dart';
import '../util/wait_for_ex.dart';

import 'dcli_function.dart';
import 'echo.dart';

///
/// Reads a line of text from stdin with an optional prompt.
///
/// If the user immediately enters newline without
/// entering any text then an empty string will
/// be returned.
///
/// ```dart
/// String response = ask("Do you like me?");
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
/// If a [defaultValue] is passed then it is displayed and the user
/// fails to enter a value (just hits the enter key) then the
/// [defaultValue] is returned.
///
/// If you pass in a [defaultValue] which doesn't pass the [validator] test then
/// an [AskValidatorException] will be thrown.
///
/// Passing a [defaultValue] also modifies the prompt to display the value:
///
/// ```dart
/// var result = ask('How many', defaultValue: '5');
/// > 'How many [5]'
/// ```
/// [ask] will throw an [AskValidatorException] if the defaultValue doesn't match
/// the given [validator].
///
///
/// The [validator] is called each time the user hits enter.
/// The [validator] allows you to normalise and validate the user's
/// input. The [validator] must return the normalised value which
/// will be the value returned by [ask].
/// If the [validator] detects an invalid input then you MUST
/// throw [AskValidatorException(error)]. The error will
/// be displayed on the console and the user reprompted.
/// You can color code the error using any of the dcli
/// color functions.  By default all input is considered valid.
///
///```dart
///   var subject = ask( 'Subject');
///   subject = ask( 'Subject', validator: Ask.required);
///   subject = ask( 'Subject', validator: AskMinLength(10));
///   var name = ask( 'What is your name?', validator: Ask.alpha);
///   var age = ask( 'How old are you?', validator: Ask.integer);
///   var username = ask( 'Username?', validator: Ask.email);
///   var password = ask( 'Password?', hidden: true, validator: AskValidatorMulti([Ask.alphaNumeric, AskLength(10,16)]));
///   var color = ask( 'Favourite colour?', AskListValidator(['red', 'green', 'blue']));
///
///```
String ask(String prompt,
        {bool toLower = false, bool hidden = false, String defaultValue, AskValidator validator = Ask.any}) =>
    Ask()._ask(prompt, toLower: toLower, hidden: hidden, defaultValue: defaultValue, validator: validator);

/// [confirm] is a specialized version of ask that returns true or
/// false based on the value entered.
/// Accepted values are y|t|true|yes and n|f|false|no (case insenstiive).
/// If the user enters an unknown value an error is printed
/// and they are reprompted.
bool confirm(String prompt, {bool defaultValue}) {
  bool result;
  var matched = false;

  if (defaultValue == null) {
    prompt += ' (y/n):';
  } else {
    if (defaultValue == true) {
      prompt += ' (Y/n):';
    } else {
      prompt += ' (y/N):';
    }
  }

  while (!matched) {
    var entered = Ask()._ask(prompt, toLower: true, hidden: false, validator: Ask.any);
    var lower = entered.trim().toLowerCase();

    if (lower.isEmpty && defaultValue != null) {
      lower = defaultValue ? 'true' : 'false';
    }

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

/// Class for [ask] and related code.
class Ask extends DCliFunction {
  static const int _backspace = 127;
  static const int _space = 32;
  static const int _ = 8;

  ///
  /// Reads user input from stdin and returns it as a string.
  /// [prompt]
  String _ask(String prompt, {bool toLower, bool hidden, AskValidator validator, String defaultValue}) {
    Settings().verbose('ask:  $prompt toLower: $toLower hidden: $hidden defaultValue: $defaultValue');

    /// check the caller isn't being silly
    if (defaultValue != null) {
      try {
        validator.validate(defaultValue);
      } on AskValidatorException catch (e) {
        throw AskValidatorException('The [defaultValue] $defaultValue failed the validator: ${e.message}');
      }
      prompt = '$prompt [$defaultValue]';
    }

    String line;
    var valid = false;
    do {
      if (prompt != null) {
        echo('$prompt ', newline: false);
      }

      if (hidden == true && stdin.hasTerminal) {
        line = _readHidden();
      } else {
        line = stdin.readLineSync(encoding: Encoding.getByName('utf-8'), retainNewlines: false);
      }

      line ??= '';

      if (line.isEmpty && defaultValue != null) {
        line = defaultValue;
      }

      if (toLower == true) {
        line = line.toLowerCase();
      }

      try {
        Settings().verbose('ask: pre validation "$line"');
        line = validator.validate(line);
        Settings().verbose('ask: post validation "$line"');
        valid = true;
      } on AskValidatorException catch (e) {
        print(e.message);
      }

      Settings().verbose('ask: result $line');
    } while (!valid);

    return line;
  }

  String _readHidden() {
    var value = <int>[];

    try {
      stdin.echoMode = false;
      stdin.lineMode = false;
      int char;
      do {
        char = stdin.readByteSync();
        if (char != 10) {
          if (char == _backspace) {
            if (value.isNotEmpty) {
              // move back a character,
              // print a space an move back again.
              // required to clear the current character
              // move back one space.
              stdout.writeCharCode(_);
              stdout.writeCharCode(_space);
              stdout.writeCharCode(_);
              value.removeLast();
            }
          } else {
            stdout.write('*');
            // we must wait for flush as only one flush can be outstanding at a time.
            waitForEx<void>(stdout.flush());
            value.add(char);
          }
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

  /// The default validator that considers any input as valid
  static const AskValidator any = _AskAny();

  /// The user must enter a non-empty string.
  /// Whitespace will be trimmed before the string is tested.
  static const AskValidator required = _AskRequired();

  /// validates that the input is an email address
  static const AskValidator email = _AskEmail();

  /// validates that the input is a fully qualified domian name.
  static const AskValidator fqdn = _AskFQDN();

  /// validates that the input is a date.
  static const AskValidator date = _AskDate();

  /// validates that the input is an integer
  static const AskValidator integer = _AskInteger();

  /// validates that the input is a decimal
  static const AskValidator decimal = _AskDecimal();

  /// validates that the input is only alpha characters
  static const AskValidator alpha = _AskAlpha();

  /// validates that the input is only alphanumeric characters.
  static const AskValidator alphaNumeric = _AskAlphaNumeric();

  /// validates that the input is a valid ip address (v4 or v6)
  /// Use the AskIPAddress class directly if you want just a
  /// v4 or v6 address.
  static const AskValidator ipAddress = AskValidatorIPAddress();
}

/// Thrown when an [Askvalidator] detects an invalid input.
class AskValidatorException extends DCliException {
  /// validator with a [message] indicating the error.
  AskValidatorException(String message) : super(message);
}

/// Base class for all [AskValidator]s.
/// You can add your own by extending this class.
abstract class AskValidator {
  /// allows us to make validators consts.
  const AskValidator();

  /// This method is called by [ask] to valiate the
  /// string entered by the user.
  /// It should throw an AskValidatorException if the input
  /// is invalid.
  /// The validate method is called when the user hits the enter key.
  String validate(String line);
}

/// The default validator that considers any input as valid
class _AskAny extends AskValidator {
  const _AskAny();
  @override
  String validate(String line) {
    return line;
  }
}

/// The user must enter a non-empty string.
/// Whitespace will be trimmed before the string is tested.
///
class _AskRequired extends AskValidator {
  const _AskRequired();
  @override
  String validate(String line) {
    line = line.trim();
    if (line.isEmpty) {
      throw AskValidatorException(red('You must enter a value.'));
    }
    return line;
  }
}

class _AskEmail extends AskValidator {
  const _AskEmail();
  @override
  String validate(String line) {
    line = line.trim();

    if (!isEmail(line)) {
      throw AskValidatorException(red('Invalid email address.'));
    }
    return line;
  }
}

class _AskFQDN extends AskValidator {
  const _AskFQDN();
  @override
  String validate(String line) {
    line = line.trim().toLowerCase();

    if (!isFQDN(line)) {
      throw AskValidatorException(red('Invalid FQDN.'));
    }
    return line;
  }
}

class _AskDate extends AskValidator {
  const _AskDate();
  @override
  String validate(String line) {
    line = line.trim();

    if (!isDate(line)) {
      throw AskValidatorException(red('Invalid date.'));
    }
    return line;
  }
}

class _AskInteger extends AskValidator {
  const _AskInteger();
  @override
  String validate(String line) {
    line = line.trim();
    Settings().verbose('AskInteger: $line');

    if (!isInt(line)) {
      throw AskValidatorException(red('Invalid integer.'));
    }
    return line;
  }
}

class _AskDecimal extends AskValidator {
  const _AskDecimal();
  @override
  String validate(String line) {
    line = line.trim();

    if (!isFloat(line)) {
      throw AskValidatorException(red('Invalid decimal number.'));
    }
    return line;
  }
}

class AskValidatorRange extends AskValidator {
  final num minValue;
  final num maxValue;

  const AskValidatorRange(this.minValue, this.maxValue);
  @override
  String validate(String line) {
    line = line.trim();
    var value = num.tryParse(line);
    if (value == null) {
      throw AskValidatorException(red('Must be a number.'));
    }

    if (value < minValue) {
      throw AskValidatorException(red('The number must be greater than or equal to $minValue.'));
    }

    if (value > maxValue) {
      throw AskValidatorException(red('The number must be less than or equal to $maxValue.'));
    }

    return line;
  }
}

class _AskAlpha extends AskValidator {
  const _AskAlpha();
  @override
  String validate(String line) {
    line = line.trim();

    if (!isAlpha(line)) {
      throw AskValidatorException(red('Alphabetical characters only.'));
    }
    return line;
  }
}

class _AskAlphaNumeric extends AskValidator {
  const _AskAlphaNumeric();
  @override
  String validate(String line) {
    line = line.trim();

    if (!isAlphanumeric(line)) {
      throw AskValidatorException(red('Alphanumerical characters only.'));
    }
    return line;
  }
}

/// Validates that input is a IP address
/// By default both v4 and v6 addresses are valid
/// Pass a [version] to limit the input to one or the
/// other. If passed [version] must be 4 or 6.
class AskValidatorIPAddress extends AskValidator {
  /// IP version (on 4 and 6 are valid versions.)
  final int version;

  /// Validates that input is a IP address
  /// By default both v4 and v6 addresses are valid
  /// Pass a [version] to limit the input to one or the
  /// other. If passed [version] must be 4 or 6.
  const AskValidatorIPAddress({this.version});

  @override
  String validate(String line) {
    assert(version == null || version == 4 || version == 6);

    line = line.trim();

    if (!isIP(line, version)) {
      throw AskValidatorException(red('Invalid IP Address.'));
    }
    return line;
  }
}

/// Validates that the entered line is no longer
/// than [maxLength].
class AskValidatorMaxLength extends AskValidator {
  /// the maximum allows length for the entered string.
  final int maxLength;

  /// Validates that the entered line is no longer
  /// than [maxLength].
  const AskValidatorMaxLength(this.maxLength);
  @override
  String validate(String line) {
    line = line.trim();

    if (line.length > maxLength) {
      throw AskValidatorException(red('You have exceeded the maximum length of $maxLength characters.'));
    }
    return line;
  }
}

/// Validates that the entered line is not less
/// than [minLength].
class AskValidatorMinLength extends AskValidator {
  /// the minimum allows length of the string.
  final int minLength;

  /// Validates that the entered line is not less
  /// than [minLength].
  const AskValidatorMinLength(this.minLength);
  @override
  String validate(String line) {
    line = line.trim();

    if (line.length < minLength) {
      throw AskValidatorException(red('You must enter at least $minLength characters.'));
    }
    return line;
  }
}

/// Validates that the length of the entered text
/// as at least [minLength] but no more than [maxLength].
class AskValidatorLength extends AskValidator {
  AskValidatorMulti _validator;

  /// Validates that the length of the entered text
  /// as at least [minLength] but no more than [maxLength].
  AskValidatorLength(int minLength, int maxLength) {
    _validator = AskValidatorMulti([
      AskValidatorMinLength(minLength),
      AskValidatorMaxLength(maxLength),
    ]);
  }
  @override
  String validate(String line) {
    line = line.trim();

    line = _validator.validate(line);
    return line;
  }
}

/// Allows you to combine multiple validators
/// When the user hits enter we apply the list
/// of [valiadators] in the provided order.
/// Validation stops when the first validator fails.
class AskValidatorMulti extends AskValidator {
  final List<AskValidator> _validators;

  /// Allows you to combine multiple validators
  /// When the user hits enter we apply the list
  /// of [valiadators] in the provided order.
  /// Validation stops when the first validator fails.
  AskValidatorMulti(this._validators);
  @override
  String validate(String line) {
    line = line.trim();

    for (var validator in _validators) {
      line = validator.validate(line);
    }
    return line;
  }
}

/// Checks that the input matches one of the
/// provided [validItems].
/// If the validator fails it prints out the
/// list of available inputs.
class AskValidatorList extends AskValidator {
  /// The list of allowed values.
  final List<String> validItems;

  /// Checks that the input matches one of the
  /// provided [validItems].
  /// If the validator fails it prints out the
  /// list of available inputs.
  /// By default [caseSensitive] matches are off.
  AskValidatorList(this.validItems, {bool caseSensitive = false});
  @override
  String validate(String line) {
    line = line.trim();
    var found = false;
    for (var item in validItems) {
      if (line == item) {
        found = true;
        break;
      }
    }
    if (!found) {
      throw AskValidatorException(red('The valid responses are ${validItems.join(' | ')}.'));
    }

    return line;
  }
}
