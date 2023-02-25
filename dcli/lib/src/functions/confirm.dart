/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import '../../dcli.dart';

typedef CustomConfirmPrompt = String Function(
    String prompt,
    // ignore: avoid_positional_boolean_parameters
    bool? defaultValue);

/// [confirm] is a specialized version of ask that returns true or
/// false based on the value entered.
///
/// The user must enter a valid value or, if a [defaultValue]
/// is passed, the enter key.
///
/// Accepted values are y|t|true|yes and n|f|false|no (case insenstiive).
///
/// If the user enters an unknown value an error is printed
/// and they are reprompted.
///
/// The [prompt] is displayed to the user with ' (y/n)' appended.
///
/// If a [defaultValue] is passed then either the y or n will be capitalised
/// and if the user hits the enter key then the [defaultValue] will be returned.
///
/// If the script is not attached to a terminal [Terminal().hasTerminal]
/// then confirm returns immediately with the [defaultValue].
/// If there is no [defaultValue] then true is returned.
bool confirm(String prompt,
    {bool? defaultValue,
    CustomConfirmPrompt customPrompt = Confirm.defaultPrompt}) {
  var result = false;
  var matched = false;

  if (!Terminal().hasTerminal) {
    return defaultValue ?? true;
  }

  while (!matched) {
    final entered = ask(
      prompt,
      toLower: true,
      required: false,
      customPrompt: (_, __, ___) => customPrompt(prompt, defaultValue),
    );
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

// ignore: avoid_classes_with_only_static_members
class Confirm {
  // ignore: avoid_positional_boolean_parameters
  static String defaultPrompt(String prompt, bool? defaultValue) {
    var finalPrompt = prompt;

    if (defaultValue == null) {
      finalPrompt += ' (y/n):';
    } else {
      if (defaultValue == true) {
        finalPrompt += ' (Y/n):';
      } else {
        finalPrompt += ' (y/N):';
      }
    }
    return finalPrompt;
  }
}
