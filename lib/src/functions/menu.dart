import '../../dshell.dart';

/// Displays a menu with each of the provided [options].
///
///
/// e.g.
/// ```dart
/// var colors = [Color('Red'), Color('Green')];
/// var color = menu('Please select a color', colors);
/// ```
/// Results in:
///
/// 1) Red
/// 2) Green
/// Please select a color:
///
/// [menu] will display an error if the user enters a no valid
/// response and then redisplay the prompt.
///
/// Once a user selects a valid option that option is returned.
///
/// You optionally provide a [limit] which will cause the
/// menu to only display the first [limit] options passed.
///
/// If you pass a [description] lambda then description(option)
/// will be called for for each option and the resulting description
/// used.
///
/// e.g.
/// '''dart
///
/// var colors = [Color('Red'), Color('Green')];
/// var color = menu('Please select a color', colors, description: (color) => color.name);
/// '''
/// If [description] is null then [option.toString()] will be used
/// as the description for the menu option.
///

T menu<T>(String prompt, List<T> options,
    {int limit, String Function(T) description}) {
  limit ??= options.length;
  for (var i = 1; i <= limit; i++) {
    var option = options[i - 1];
    String desc;
    if (description != null) {
      desc = description(option);
    } else {
      option.toString();
    }
    var no = '$i'.padLeft(3);
    print('$no) ${desc}');
  }

  var valid = false;

  var index = -1;

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
