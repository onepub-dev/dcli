/// Returns a string wrapped with the selected ansi
/// fg color codes.
String red(String content, {int bgcolor = AnsiColor.none}) =>
    AnsiColor._color(AnsiColor.Red, content, bgcolor: bgcolor);

String black(String content, {int bgcolor = AnsiColor.White}) =>
    AnsiColor._color(AnsiColor.Black, content, bgcolor: bgcolor);

String green(String content, {int bgcolor = AnsiColor.none}) =>
    AnsiColor._color(AnsiColor.Green, content, bgcolor: bgcolor);

String blue(String content, {int bgcolor = AnsiColor.none}) =>
    AnsiColor._color(AnsiColor.Blue, content, bgcolor: bgcolor);

String yellow(String content, {int bgcolor = AnsiColor.none}) =>
    AnsiColor._color(AnsiColor.Yellow, content, bgcolor: bgcolor);

String magenta(String content, {int bgcolor = AnsiColor.none}) =>
    AnsiColor._color(AnsiColor.Magenta, content, bgcolor: bgcolor);
String cyan(String content, {int bgcolor = AnsiColor.none}) =>
    AnsiColor._color(AnsiColor.Cyan, content, bgcolor: bgcolor);

String white(String content, {int bgcolor = AnsiColor.none}) =>
    AnsiColor._color(AnsiColor.White, content, bgcolor: bgcolor);

String orange(String content, {int bgcolor = AnsiColor.none}) =>
    AnsiColor._color(AnsiColor.Orange, content, bgcolor: bgcolor);
String grey(String content,
        {double level = 0.5, int bgcolor = AnsiColor.none}) =>
    AnsiColor._color(AnsiColor.Grey(level: level), content, bgcolor: bgcolor);

class AnsiColor {
  static String reset() => _emmit(Reset);

  static String fgReset() => _emmit(FgReset);
  static String bgReset() => _emmit(BgReset);

  static String _color(int color, String content, {int bgcolor = none}) {
    String output;

    output = "${_fg(color)}${_bg(bgcolor)}${content}${_reset}";
    return output;
  }

  static String get _reset {
    return "${esc}${Reset}m";
  }

  static String _fg(int color) {
    String output;

    if (color == none) {
      output = "";
    } else if (color > 39) {
      output = "${esc}${FgColor}${color}m";
    } else {
      output = "${esc}${color}m";
    }
    return output;
  }

  // background colors are fg color + 10
  static String _bg(int color) {
    String output;

    if (color == none) {
      output = "";
    } else if (color > 49) {
      output = "${esc}${BgColor}${color + 10}m";
    } else {
      output = "${esc}${color + 10}m";
    }
    return output;
  }

  static String _emmit(String ansicode) {
    return "${esc}${ansicode}m";
  }

  /// ANSI Control Sequence Introducer, signals the terminal for new settings.
  static const esc = '\x1B[';

  /// Resets

  /// Reset fg and bg colors
  static const String Reset = "0";

  /// Defaults the terminal's fg color without altering the bg.
  static const String FgReset = "39";

  // emmit this code followed by a color code to set the fg color
  static const String FgColor = "38;5;";

// emmit this code followed by a color code to set the fg color
  static const String BgColor = "48;5;";

  /// Defaults the terminal's bg color without altering the fg.
  static const String BgReset = "49";

  /// Colors
  static const int Black = 30;
  static const int Red = 31;
  static const int Green = 32;
  static const int Yellow = 33;
  static const int Blue = 34;
  static const int Magenta = 35;
  static const int Cyan = 36;
  static const int White = 37;
  static const int Orange = 208;
  static int Grey({double level = 0.5}) =>
      232 + (level.clamp(0.0, 1.0) * 23).round();

// passing this as the background color will cause
// the background code to be suppressed resulting
// in the default background color.
  static const int none = -1;
}
