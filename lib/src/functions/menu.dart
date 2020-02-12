import '../../dshell.dart';

/// Displays a menu with each of the provided [options], prompts
/// the user to select an option and returns the selected option.
///
/// e.g.
/// ```dart
/// var colors = [Color('Red'), Color('Green')];
/// var color = menu('Please select a color', colors);
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
/// If you pass a [description] lambda then [description] function
/// will be called for for each option and the resulting description
/// used to display the option in the menu.
///
/// e.g.
/// ```dart
///
/// var colors = [Color('Red'), Color('Green')];
/// var color = menu('Please select a color', colors, description: (color) => color.name);
/// ```
///
/// If [description] is null then [option.toString()] will be used
/// as the description for the menu option.
///
/// When a [limit] is applied the menu will display the first [limit]
/// options. If you specify [fromStart: false] then the menu will display the
/// last [limit] options.
///

T menu<T>(String prompt, List<T> options,
    {int limit, String Function(T) description, bool fromStart = true}) {
  limit ??= options.length;

  var displayList = options;
  if (fromStart == false) {
    // get the last [limit] options
    displayList = options.sublist(options.length - limit);
  }

  // display each option.
  for (var i = 1; i <= limit; i++) {
    var option = displayList[i - 1];
    String desc;
    if (description != null) {
      desc = description(option);
    } else {
      desc = option.toString();
    }
    var no = '$i'.padLeft(3);
    print('$no) ${desc}');
  }

  var valid = false;

  var index = -1;

  // loop until the user enters a valid selection.
  while (!valid) {
    var selected = ask(prompt: prompt);
    if (selected == null) continue;

    index = int.tryParse(selected);
    if (index == null) {
      printerr('Value must be an integer from 1 to $limit');
      continue;
    }

    if (index < 1 || index > limit) {
      printerr('Invalid selection');
      continue;
    }
    valid = true;
  }
  return options[index - 1];
}
