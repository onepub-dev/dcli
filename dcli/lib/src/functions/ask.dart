/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:convert';
import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:meta/meta.dart';
import 'package:validators2/validators2.dart';

import '../../dcli.dart';

typedef CustomAskPrompt = String Function(
    String prompt,
    String? defaultValue,
    // ignore: avoid_positional_boolean_parameters
    bool hidden);

///
/// Reads a line of text from stdin with an optional prompt.
///
///
/// ```dart
/// String response = ask("Do you like me?");
/// ```
///
/// If the script is not attached to terminal [Terminal().hasTerminal]
/// then ask returns immediatly with the [defaultValue]. If no [defaultValue]
/// is passed then an empty string is returned. No validate will be applied.
///
/// If [prompt] is set then the prompt will be printed
/// to the console and the cursor placed immediately after the prompt.
///
/// Pass an empty string to suppress the prompt.
///
/// ```dart
/// var secret = ask('', required: false);
/// ```
///
/// By default the ask [required] argument is true requiring the user to enter
///  a non-empty string.
/// All whitespace is trimmed from the string before the user input
///  is validated so
/// a single space is not an accepted input.
///
/// If you set the [required] argument to false then the user can just hit
/// enter to skip past the ask prompt. If you use other validators when
///  [required] = false
/// then those validators will not be called if the entered value is empty
///  (after it is trimmed).
///
/// if [toLower] is true then the returned result is converted to lower case.
/// This can be useful if you need to compare the entered value.
///
/// If [hidden] is true then the entered values will not be echoed to the
/// console, instead '*' will be displayed. This is uesful for capturing
/// passwords.
///
/// NOTE: if there is no terminal detected then this will fallback to
/// a standard ask input in which case the hidden characters WILL BE DISPLAYED
/// as they are typed.
///
/// If a [defaultValue] is passed then it is displayed and the user
/// fails to enter a value (just hits the enter key) then the
/// [defaultValue] is returned.
///
/// Passing a [defaultValue] also modifies the prompt to display the value:
///
/// ```dart
/// var result = ask('How many', defaultValue: '5');
/// > 'How many [5]'
/// ```
/// [ask] will throw an [AskValidatorException] if the defaultValue
///  doesn't match the given [validator].
///
/// The [validator] is called each time the user hits enter.
///
/// The [validator] allows you to normalise and validate the user's
/// input. The [validator] must return the normalised value which
/// will be the value returned by [ask].
///
/// If the [validator] detects an invalid input then you MUST
/// throw [AskValidatorException(error)]. The error will
/// be displayed on the console and the user reprompted.
/// You can color code the error using any of the dcli
/// color functions.  By default all input is considered valid.
///
///```dart
///   var subject = ask( 'Subject');
///   subject = ask( 'Subject', required: true);
///   subject = ask( 'Subject', validator: Ask.minLength(10));
///   var name = ask( 'What is your name?', validator: Ask.alpha);
///   var age = ask( 'How old are you?', validator: Ask.integer);
///   var username = ask( 'Username?', validator: Ask.email);
///   var password = ask( 'Password?', hidden: true,
///     validator: Ask.all([Ask.alphaNumeric, AskValidatorLength(10,16)]));
///   var color = ask( 'Favourite colour?'
///     , Ask.inList(['red', 'green', 'blue']));
///
///```
String ask(
  String prompt, {
  bool toLower = false,
  bool hidden = false,
  bool required = true,
  String? defaultValue,
  CustomAskPrompt customPrompt = Ask.defaultPrompt,
  AskValidator validator = Ask.dontCare,
}) =>
    Ask()._ask(
      prompt,
      toLower: toLower,
      hidden: hidden,
      required: required,
      defaultValue: defaultValue,
      customPrompt: customPrompt,
      validator: validator,
    );

// ignore: avoid_clas
/// Class for [ask] and related code.
class Ask extends core.DCliFunction {
  static const int _backspace = 127;
  static const int _space = 32;
  static const int _ = 8;

  ///
  /// Reads user input from stdin and returns it as a string.
  /// [prompt]
  String _ask(
    String prompt, {
    required bool hidden,
    required bool required,
    required AskValidator validator,
    required CustomAskPrompt customPrompt,
    bool toLower = false,
    String? defaultValue,
  }) {
    ArgumentError.checkNotNull(prompt);
    core.verbose(
      () => 'ask:  $prompt toLower: $toLower hidden: $hidden '
          'required: $required '
          'defaultValue: ${hidden ? '******' : defaultValue}',
    );

    if (!Terminal().hasTerminal) {
      return defaultValue ?? '';
    }
    final finalPrompt = customPrompt(prompt, defaultValue, hidden);

    var line = '';
    var valid = false;
    do {
      echo('$finalPrompt ');

      if (hidden == true && stdin.hasTerminal) {
        line = _readHidden();
      } else {
        line = stdin.readLineSync(encoding: Encoding.getByName('utf-8')!) ?? '';
      }

      if (line.isEmpty && defaultValue != null) {
        line = defaultValue;
      }

      if (toLower == true) {
        line = line.toLowerCase();
      }

      try {
        if (required) {
          const _AskRequired().validate(line);
        }
        verbose(() => 'ask: pre validation "$line"');
        line = validator.validate(line);
        verbose(() => 'ask: post validation "$line"');
        valid = true;
      } on AskValidatorException catch (e) {
        print(e.message);
      }

      verbose(() => 'ask: result $line');
    } while (!valid);

    return line;
  }

  String _readHidden() {
    final value = <int>[];

    try {
      stdin.echoMode = false;
      stdin.lineMode = false;
      int char;
      do {
        char = stdin.readByteSync();
        if (char != 10 && char != 13) {
          if (char == _backspace) {
            if (value.isNotEmpty) {
              // move back a character,
              // print a space an move back again.
              // required to clear the current character
              // move back one space.
              stdout
                ..writeCharCode(_)
                ..writeCharCode(_space)
                ..writeCharCode(_);
              value.removeLast();
            }
          } else {
            stdout.write('*');
            // we must wait for flush as only one flush can
            // be outstanding at a time.
            // ignore: discarded_futures
            waitForEx<void>(stdout.flush());
            value.add(char);
          }
        }
      } while (char != 10 && char != 13);
    } finally {
      stdin.lineMode = true;
      stdin.echoMode = true;
    }

    // output a newline as we have suppressed it.
    print('');

    // return the entered value as a String.
    return Encoding.getByName('utf-8')!.decode(value);
  }

  static String defaultPrompt(
      String prompt,
      String? defaultValue,
      // ignore: avoid_positional_boolean_parameters
      bool hidden) {
    var result = prompt;

    /// completely suppress the default value and the prompt if
    /// the prompt is empty.
    if (defaultValue != null && prompt.isNotEmpty) {
      /// don't display the default value if hidden is true.
      result = '$prompt [${hidden ? '******' : defaultValue}]';
    }
    return result;
  }

  /// The default validator that considers any input as valid
  static const AskValidator dontCare = _AskDontCare();

  /// Takes an array of validators. The input is considered valid if any one
  /// of the validators returns true.
  /// The validators are processed in order from left to right.
  /// If none of the validators pass then the error from the first validator
  /// that failed is returned. The implications is that the user will only
  /// ever see the error from the first validator.
  static AskValidator any(List<AskValidator> validators) =>
      _AskValidatorAny(validators);

  /// Takes an array of validators. The input is considered valid only if
  /// everyone of the validators pass.
  ///
  /// The validators are processed in order from left to right.
  ///
  /// The error from the first validator that failes is returned.
  ///
  /// It should be noted that the user input is passed to each validator in turn
  /// and each validator has the opportunity to modify the input. As a result
  /// a validators will be operating on a version of the input
  /// that has been processed  by all validators that appear
  /// earlier in the list.
  static AskValidator all(List<AskValidator> validators) =>
      _AskValidatorAll(validators);

  /// Validates that input is a IP address
  /// By default both v4 and v6 addresses are valid
  /// Pass a [version] to limit the input to one or the
  /// other. If passed [version] must be [AskValidatorIPAddress.ipv4]
  /// or [AskValidatorIPAddress.ipv6].
  static AskValidator ipAddress({int version = AskValidatorIPAddress.either}) =>
      AskValidatorIPAddress(version: version);

  /// Validates the input against a regular expression
  /// ```dart
  /// ask('Variable Name:', validator: Ask.regExp(r'^[a-zA-Z_]+$'));
  /// ```
  static AskValidator regExp(String regExp, {String? error}) =>
      _AskRegExp(regExp, error: error);

  /// Validates that the entered line is no longer
  /// than [maxLength].
  static AskValidator lengthMax(int maxLength) =>
      _AskValidatorMaxLength(maxLength);

  /// Validates that the entered line is not less
  /// than [minLength].
  static AskValidator lengthMin(int minLength) =>
      _AskValidatorMinLength(minLength);

  /// Validates that the length of the entered text
  /// as at least [minLength] but no more than [maxLength].
  static AskValidator lengthRange(int minLength, int maxLength) =>
      _AskValidatorLength(minLength, maxLength);

  /// Validates that a number is between a minimum value (inclusive)
  /// and a maximum value (inclusive).
  static AskValidator valueRange(num minValue, num maxValue) =>
      _AskValidatorValueRange(minValue, maxValue);

  /// Checks that the input matches one of the
  /// provided [validItems].
  /// If the validator fails it prints out the
  /// list of available inputs.
  /// By default [caseSensitive] matches are off.
  static AskValidator inList(
    List<Object> validItems, {
    bool caseSensitive = false,
  }) =>
      _AskValidatorList(validItems, caseSensitive: caseSensitive);

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
}

/// Thrown when an [AskValidator] detects an invalid input.
class AskValidatorException extends DCliException {
  /// validator with a [message] indicating the error.
  AskValidatorException(super.message);
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
  /// If the validation succeeds the validated line is returned.
  @visibleForTesting
  String validate(String line);
}

/// The default validator that considers any input as valid
class _AskDontCare extends AskValidator {
  const _AskDontCare();
  @override
  String validate(String line) => line;
}

/// The user must enter a non-empty string.
/// Whitespace will be trimmed before the string is tested.
///
class _AskRequired extends AskValidator {
  const _AskRequired();
  @override
  String validate(String line) {
    final finalLine = line.trim();
    if (finalLine.isEmpty) {
      throw AskValidatorException(red('You must enter a value.'));
    }
    return finalLine;
  }
}

class _AskEmail extends AskValidator {
  const _AskEmail();
  @override
  String validate(String line) {
    final finalLine = line.trim();

    if (!isEmail(finalLine)) {
      throw AskValidatorException(red('Invalid email address.'));
    }
    return finalLine;
  }
}

class _AskFQDN extends AskValidator {
  const _AskFQDN();
  @override
  String validate(String line) {
    final finalLine = line.trim().toLowerCase();

    if (!isFQDN(finalLine)) {
      throw AskValidatorException(red('Invalid FQDN.'));
    }
    return finalLine;
  }
}

/// Validates the input against a regular expression
/// ```dart
/// ask('Variable Name:', validator: Ask.regExp(r'^[a-zA-Z_]+$'));
/// ```
///
class _AskRegExp extends AskValidator {
  /// Creates a regular expression based validator.
  /// You can customise the error message by providing a value for [error].
  _AskRegExp(this.regexp, {String? error}) {
    _regexp = RegExp(regexp);
    _error = error ?? 'Input does not match: $regexp';
  }

  final String regexp;
  late final RegExp _regexp;
  late final String _error;

  @override
  String validate(String line) {
    final finalLine = line.trim();

    if (!_regexp.hasMatch(finalLine)) {
      throw AskValidatorException(red(_error));
    }
    return finalLine;
  }
}

class _AskDate extends AskValidator {
  const _AskDate();
  @override
  String validate(String line) {
    final finalLine = line.trim();

    if (!isDate(finalLine)) {
      throw AskValidatorException(red('Invalid date.'));
    }
    return finalLine;
  }
}

class _AskInteger extends AskValidator {
  const _AskInteger();
  @override
  String validate(String line) {
    final finalLine = line.trim();
    verbose(() => 'AskInteger: $finalLine');

    if (!isInt(finalLine)) {
      throw AskValidatorException(red('Invalid integer.'));
    }
    return finalLine;
  }
}

class _AskDecimal extends AskValidator {
  const _AskDecimal();
  @override
  String validate(String line) {
    final finalline = line.trim();

    if (!isFloat(finalline)) {
      throw AskValidatorException(red('Invalid decimal number.'));
    }
    return finalline;
  }
}

class _AskAlpha extends AskValidator {
  const _AskAlpha();
  @override
  String validate(String line) {
    final finalline = line.trim();

    if (!isAlpha(finalline)) {
      throw AskValidatorException(red('Alphabetical characters only.'));
    }
    return finalline;
  }
}

class _AskAlphaNumeric extends AskValidator {
  const _AskAlphaNumeric();
  @override
  String validate(String line) {
    final finalline = line.trim();

    if (!isAlphanumeric(finalline)) {
      throw AskValidatorException(red('Alphanumerical characters only.'));
    }
    return finalline;
  }
}

/// Validates that input is a IP address
/// By default both v4 and v6 addresses are valid
/// Pass a [version] to limit the input to one or the
/// other. If passed [version] must be [ipv4] or [ipv6].
class AskValidatorIPAddress extends AskValidator {
  /// Validates that input is a IP address
  /// By default both v4 and v6 addresses are valid
  /// Pass a [version] to limit the input to one or the
  /// other. If passed [version] must be 4 or 6.
  const AskValidatorIPAddress({this.version = either});

  /// The ip address may be either [ipv4] or [ipv6].
  static const int either = 0;

  /// The ip address must be an ipv4 address.
  static const int ipv4 = 4;

  /// The ip address must be an ipv6 address.
  static const int ipv6 = 6;

  /// IP version (on 4 and 6 are valid versions.)
  final int version;

  @override
  String validate(String line) {
    assert(
      version == either || version == ipv4 || version == ipv6,
      'The version nmust be AskValidatorIPAddress.either or '
      'AskValidatorIPAddress.ipv4 or AskValidatorIPAddress.ipv6',
    );

    final finalline = line.trim();

    var validatorsVersion = IPVersion.any;
    switch (version) {
      case ipv4:
        validatorsVersion = IPVersion.ipV4;
        break;
      case ipv6:
        validatorsVersion = IPVersion.ipV6;
        break;
    }

    if (!isIP(finalline, version: validatorsVersion)) {
      throw AskValidatorException(red('Invalid IP Address.'));
    }
    return finalline;
  }
}

/// Validates that the entered line is no longer
/// than [maxLength].
class _AskValidatorMaxLength extends AskValidator {
  /// Validates that the entered line is no longer
  /// than [maxLength].
  const _AskValidatorMaxLength(this.maxLength);
  @override
  String validate(String line) {
    final finalline = line.trim();

    if (finalline.length > maxLength) {
      throw AskValidatorException(
        red(
          'You have exceeded the maximum length of $maxLength characters.',
        ),
      );
    }
    return finalline;
  }

  /// the maximum allows length for the entered string.
  final int maxLength;
}

/// Validates that the entered line is not less
/// than [minLength].
class _AskValidatorMinLength extends AskValidator {
  /// Validates that the entered line is not less
  /// than [minLength].
  const _AskValidatorMinLength(this.minLength);
  @override
  String validate(String line) {
    final finalline = line.trim();

    if (finalline.length < minLength) {
      throw AskValidatorException(
        red('You must enter at least $minLength characters.'),
      );
    }
    return finalline;
  }

  /// the minimum allows length of the string.
  final int minLength;
}

/// Validates that the length of the entered text
// ignore: comment_references
/// as at least [minLength] but no more than [maxLength].
class _AskValidatorLength extends AskValidator {
  /// Validates that the length of the entered text
  /// as at least [minLength] but no more than [maxLength].
  _AskValidatorLength(int minLength, int maxLength) {
    _validator = _AskValidatorAll([
      _AskValidatorMinLength(minLength),
      _AskValidatorMaxLength(maxLength),
    ]);
  }
  late _AskValidatorAll _validator;

  @override
  String validate(String line) {
    final finalline = line.trim();

    return _validator.validate(finalline);
  }
}

class _AskValidatorValueRange extends AskValidator {
  const _AskValidatorValueRange(this.minValue, this.maxValue);

  final num minValue;
  final num maxValue;

  @override
  String validate(String line) {
    final finalline = line.trim();

    final value = num.tryParse(finalline);
    if (value == null) {
      throw AskValidatorException(red('Must be a number.'));
    }

    if (value < minValue) {
      throw AskValidatorException(
        red('The number must be greater than or equal to $minValue.'),
      );
    }

    if (value > maxValue) {
      throw AskValidatorException(
        red('The number must be less than or equal to $maxValue.'),
      );
    }

    return finalline;
  }
}

/// Takes an array of validators. The input is considered valid only if
/// everyone of the validators pass.
///
/// The validators are processed in order from left to right.
///
/// The error from the first validator that failes is returned.
///
/// It should be noted that the user input is passed to each validator in turn
/// and the validator has the opportunity to modify the input. As a result
/// a validators will be operating on a version of the input
/// that has been processed  by all validators that appear earlier in the list.
class _AskValidatorAll extends AskValidator {
  /// Takes an array of validators. The input is considered valid only if
  /// everyone of the validators pass.
  ///
  /// The validators are processed in order from left to right.
  ///
  /// The error from the first validator that failes is returned.
  ///
  /// It should be noted that the user input is passed to each validator in turn
  /// and the validator has the opportunity to modify the input. As a result
  /// a validators will be operating on a version of the input
  /// that has been processed  by all validators that appear earlier
  /// in the list.
  _AskValidatorAll(this._validators);
  final List<AskValidator> _validators;

  @override
  String validate(String line) {
    var finalline = line.trim();

    for (final validator in _validators) {
      finalline = validator.validate(finalline);
    }
    return finalline;
  }
}

/// Takes an array of validators. The input is considered valid if any one
/// of the validators returns true.
/// The validators are processed in order from left to right.
/// If none of the validators pass then the error from the first validator
/// that failed is returned. The implications is that the user will only
/// ever see the error from the first validator.
///
/// It should be noted that the user input is passed to each validator in turn
/// and each validator has the opportunity to modify the input. As a result
/// a validators will be operating on a version of the input
/// that has been processed  by all validators that appear earlier in the list.
class _AskValidatorAny extends AskValidator {
  /// Takes an array of validators. The input is considered valid if any one
  /// of the validators returns true.
  /// The validators are processed in order from left to right.
  /// If none of the validators pass then the error from the first validator
  /// that failed is returned. The implications is that the user will only
  /// ever see the error from the first validator.
  ///
  /// It should be noted that the user input is passed to each validator in turn
  /// and each validator has the opportunity to modify the input. As a result
  /// a validators will be operating on a version of the input
  /// that has been processed  by all successful validators
  /// that appear earlier in the list.
  ///
  /// Validators that fail don't get an opportunity to modify the input.
  _AskValidatorAny(this._validators);

  final List<AskValidator> _validators;

  @override
  String validate(String line) {
    var finalline = line.trim();

    AskValidatorException? firstFailure;

    var onePassed = false;

    for (final validator in _validators) {
      try {
        finalline = validator.validate(finalline);
        onePassed = true;
      } on AskValidatorException catch (e) {
        firstFailure ??= e;
      }
    }
    if (!onePassed) {
      throw firstFailure!;
    }
    return finalline;
  }
}

/// Checks that the input matches one of the
/// provided [validItems].
/// If the validator fails it prints out the
/// list of available inputs.
class _AskValidatorList extends AskValidator {
  /// Checks that the input matches one of the
  /// provided [validItems].
  /// If the validator fails it prints out the
  /// list of available inputs.
  /// By default [caseSensitive] matches are off.
  _AskValidatorList(this.validItems, {this.caseSensitive = false});

  /// The list of allowed values.
  final List<Object> validItems;
  final bool caseSensitive;

  @override
  String validate(String line) {
    var finalline = line.trim();

    if (caseSensitive) {
      finalline = finalline.toLowerCase();
    }
    var found = false;
    for (final item in validItems) {
      var itemValue = item.toString();
      if (caseSensitive) {
        itemValue = itemValue.toLowerCase();
      }

      if (finalline == itemValue) {
        found = true;
        break;
      }
    }
    if (!found) {
      throw AskValidatorException(
        red('The valid responses are ${validItems.join(' | ')}.'),
      );
    }

    return finalline;
  }
}
