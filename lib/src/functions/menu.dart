import 'dart:math';
import 'package:meta/meta.dart';

import '../../dshell.dart';
import '../script/command_line_runner.dart';

/// Displays a menu with each of the provided [options], prompts
/// the user to select an option and returns the selected option.
///
/// e.g.
/// ```dart
/// var colors = [Color('Red'), Color('Green')];
/// var color = menu(prompt: 'Please select a color', options: colors);
/// ```
/// Results in:
///```
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
/// var color = menu(prompt: 'Please select a color', options: colors, format: (color) => color.name);
/// ```
///
/// If [format] is null then [option.toString()] will be used
/// as the format for the menu option.
///
/// When a [limit] is applied the menu will display the first [limit]
/// options. If you specify [fromStart: false] then the menu will display the
/// last [limit] options.
///

T menu<T>(
    {@required String prompt,
    @required List<T> options,
    T defaultValue,
    int limit,
    String Function(T) format,
    bool fromStart = true}) {
  if (options == null || options.isEmpty) {
    throw ArgumentError(
        'The list of [options] passed to menu(options: ) was empty.');
  }
  if (prompt == null) {
    throw ArgumentError('The [prompt] passed to menu(prompt: ) was null.');
  }
  limit ??= options.length;

  var displayList = options;
  if (fromStart == false) {
    // get the last [limit] options
    displayList = options.sublist(min(options.length, options.length - limit));
  }

  // on the way in we check that the default value acutally exists in the list.
  int defaultOption;
  // display each option.
  for (var i = 1; i <= limit; i++) {
    var option = displayList[i - 1];

    if (option == defaultValue) {
      defaultOption = i;
    }
    String desc;
    if (format != null) {
      desc = format(option);
    } else {
      desc = option.toString();
    }
    var no = '$i'.padLeft(3);
    if (defaultValue != null && defaultValue == option) {
      /// highlight the default value.
      print('${green('$no) $desc')}');
    } else {
      print('$no) $desc');
    }
  }

  if (defaultValue != null && defaultOption == null) {
    throw ArgumentError(
        "The [defaultValue] $defaultValue doesn't match any of the passed [options]."
        ' Check the == operator for ${options[0].runtimeType}.');
  }

  var valid = false;

  var index = -1;

  // loop until the user enters a valid selection.
  while (!valid) {
    var selected = ask(
        prompt: prompt,
        defaultValue: defaultOption.toString(),
        validator: MenuRange(limit));
    if (selected == null) continue;
    valid = true;
    index = int.parse(selected);
  }

  return options[index - 1];
}

class MenuRange extends AskValidator {
  final int limit;

  const MenuRange(this.limit);
  @override
  String validate(String line) {
    line = line.trim();
    var value = num.tryParse(line);
    if (value == null) {
      throw AskValidatorException(
          red('Value must be an integer from 1 to $limit'));
    }

    if (value < 1 || value > limit) {
      throw AskValidatorException('Invalid selection.');
    }

    return line;
  }
}
