import 'dart:math';
import 'package:meta/meta.dart';

import '../../dcli.dart';

/// Displays a menu with each of the provided [options], prompts
/// the user to select an option and returns the selected option.
///
/// e.g.
/// ```dart
/// var colors = [Color('Red'), Color('Green')];
/// var color = menu( 'Please select a color', options: colors);
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
/// If you pass a [defaultOption] the matching option is highlighted in green in the menu
/// and if the user hits enter without entering a value the [defaultOption] is returned.
///
/// If the [defaultOption] does not match any the supplied [options] then an ArgumentError is thrown.
///

T menu<T>(
    {@required String prompt,
    @required List<T> options,
    T defaultOption,
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
  String defaultIndex;
  // display each option.
  for (var i = 1; i <= limit; i++) {
    final option = displayList[i - 1];

    if (option == defaultOption) {
      defaultIndex = i.toString();
    }
    String desc;
    if (format != null) {
      desc = format(option);
    } else {
      desc = option.toString();
    }
    final no = '$i'.padLeft(3);
    if (defaultOption != null && defaultOption == option) {
      /// highlight the default value.
      print(green('$no) $desc'));
    } else {
      print('$no) $desc');
    }
  }

  if (defaultOption != null && defaultIndex == null) {
    throw ArgumentError(
        "The [defaultOption] $defaultOption doesn't match any of the passed [options]."
        ' Check the == operator for ${options[0].runtimeType}.');
  }

  var valid = false;

  var index = -1;

  // loop until the user enters a valid selection.
  while (!valid) {
    final selected =
        ask(prompt, defaultValue: defaultIndex, validator: MenuRange(limit));
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
    final finalline = line.trim();
    final value = num.tryParse(finalline);
    if (value == null) {
      throw AskValidatorException(
          red('Value must be an integer from 1 to $limit'));
    }

    if (value < 1 || value > limit) {
      throw AskValidatorException('Invalid selection.');
    }

    return finalline;
  }
}
