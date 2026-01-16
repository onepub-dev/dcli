/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:math';

import '../../dcli.dart';

String _noFormat<T>(T option) => option.toString();

typedef CustomMenuPrompt = String Function(
    String prompt, String? defaultOption);

/// Displays a menu with each of the provided [options], prompts
/// the user to select an option and returns the selected option.
///
/// e.g.
/// ```dart
/// var colors = [Color('Red'), Color('Green')];
/// var color = menu( 'Please select a color', options: colors);
/// ```
/// Results in:
///```text
/// 1) Red
/// 2) Green
/// Please select a color:
/// ```
///
/// [menu] will display an error if the user enters a non-valid
/// response and then redisplay the prompt.
///
/// Once a user selects a valid option, that option is returned.
///
/// You may provide a [limit] which will cause the
/// menu to only display the first [limit] options passed.
///
/// If you pass a [format] lambda then the [format] function
/// will be called for for each option and the resulting format
/// used to display the option in the menu.
///
/// e.g.
/// ```dart
///
/// var colors = [Color('Red'), Color('Green')];
/// var color = menu(prompt: 'Please select a color'
///   , options: colors, format: (color) => color.name);
/// ```
///
/// If [format] is not passed [option.toString()] will be used
/// as the format for the menu option.
///
/// When a [limit] is applied the menu will display the first [limit]
/// options. If you specify [fromStart: false] then the menu will display the
/// last [limit] options.
///
/// If you pass a [defaultOption] the matching option is highlighted
/// in green in the menu
/// and if the user hits enter without entering a value the [defaultOption]
/// is returned.
///
/// If the [defaultOption] does not match any the supplied [options]
/// then an ArgumentError is thrown.
///
/// If the app is not attached to a terminal then the menu will not be
/// displayed and the [defaultOption] will be returned.
/// If there is no [defaultOption] then the first [options] will be returned.
///
/// Throws [ArgumentError].
T menu<T>(
  String prompt, {
  required List<T> options,
  T? defaultOption,
  CustomMenuPrompt customPrompt = Menu.defaultPrompt,
  int? limit,
  String Function(T)? format,
  bool fromStart = true,
}) {
  if (options.isEmpty) {
    throw ArgumentError(
      'The list of [options] passed to menu(options: ) was empty.',
    );
  }
  limit ??= options.length;
  limit = min(options.length, limit);
  format ??= _noFormat;

  if (!Terminal().hasTerminal) {
    if (defaultOption == null) {
      return options.first;
    }
    return defaultOption;
  }

  var displayList = options;
  if (!fromStart) {
    // get the last [limit] options
    displayList = options.sublist(min(options.length, options.length - limit));
  }

  // on the way in we check that the default value actually exists in the list.
  String? defaultAsString;
  // display each option.
  for (var i = 1; i <= limit; i++) {
    final option = displayList[i - 1];

    if (option == defaultOption) {
      defaultAsString = i.toString();
    }
    final desc = format(option);
    final no = '$i'.padLeft(3);
    if (defaultOption != null && defaultOption == option) {
      /// highlight the default value.
      print(green('$no) $desc'));
    } else {
      print('$no) $desc');
    }
  }

  if (defaultOption != null && defaultAsString == null) {
    throw ArgumentError(
      "The [defaultOption] $defaultOption doesn't match any "
      'of the passed [options].'
      ' Check the == operator for ${options[0].runtimeType}.',
    );
  }

  var valid = false;

  var index = -1;

  // loop until the user enters a valid selection.
  while (!valid) {
    final selected = ask(prompt,
        defaultValue: defaultAsString,
        validator: _MenuRange(limit),
        customPrompt: (_, __, ___) => customPrompt(prompt, defaultAsString));
    if (selected.isEmpty) {
      continue;
    }
    valid = true;
    index = int.parse(selected);
  }

  return options[index - 1];
}

class Menu {
  static String defaultPrompt<T>(String prompt, T? defaultValue) {
    var result = prompt;

    /// completely suppress the default value and the prompt if
    /// the prompt is empty.
    if (defaultValue != null && prompt.isNotEmpty) {
      result = '$prompt [$defaultValue]';
    }
    return result;
  }
}

class _MenuRange extends AskValidator {
  final int limit;

  const _MenuRange(this.limit);

  /// Throws [AskValidatorException].
  @override
  String validate(String line, {String? customErrorMessage}) {
    final finalline = line.trim();
    final value = num.tryParse(finalline);
    if (value == null) {
      throw AskValidatorException(
        red('Value must be an integer from 1 to $limit'),
      );
    }

    if (value < 1 || value > limit) {
      throw AskValidatorException('Invalid selection.');
    }

    return finalline;
  }
}
