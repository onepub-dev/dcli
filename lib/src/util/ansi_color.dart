/// Returns a string wrapped with the selected ansi
/// fg color codes.
String red(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor.Red, text, bgcolor: bgcolor);

String black(String text, {AnsiColor bgcolor = AnsiColor.White}) =>
    AnsiColor._apply(AnsiColor.Black, text, bgcolor: bgcolor);

String green(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor.Green, text, bgcolor: bgcolor);

String blue(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor.Blue, text, bgcolor: bgcolor);

String yellow(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor.Yellow, text, bgcolor: bgcolor);

String magenta(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor.Magenta, text, bgcolor: bgcolor);

String cyan(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor.Cyan, text, bgcolor: bgcolor);

String white(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor.White, text, bgcolor: bgcolor);

String orange(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor.Orange, text, bgcolor: bgcolor);
String grey(String text,
        {double level = 0.5, AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor.Grey(level: level), text, bgcolor: bgcolor);

class AnsiColor {
  static String reset() => _emmit(Reset);

  static String fgReset() => _emmit(FgReset);
  static String bgReset() => _emmit(BgReset);

  final int _code;
  const AnsiColor(int code) : _code = code;

  int get code => _code;

  String apply(String text, {AnsiColor bgcolor = none}) =>
      _apply(this, text, bgcolor: bgcolor);

  static String _apply(AnsiColor color, String text,
      {AnsiColor bgcolor = none}) {
    String output;

    output = '${_fg(color.code)}${_bg(bgcolor?.code)}${text}${_reset}';
    return output;
  }

  static String get _reset {
    return '${esc}${Reset}m';
  }

  static String _fg(int code) {
    String output;

    if (code == none.code) {
      output = '';
    } else if (code > 39) {
      output = '${esc}${FgColor}${code}m';
    } else {
      output = '${esc}${code}m';
    }
    return output;
  }

  // background colors are fg color + 10
  static String _bg(int code) {
    String output;

    if (code == none.code) {
      output = '';
    } else if (code > 49) {
      output = '${esc}${BgColor}${code + 10}m';
    } else {
      output = '${esc}${code + 10}m';
    }
    return output;
  }

  static String _emmit(String ansicode) {
    return '${esc}${ansicode}m';
  }

  /// ANSI Control Sequence Introducer, signals the terminal for new settings.
  static const esc = '\x1B[';

  /// Resets

  /// Reset fg and bg colors
  static const String Reset = '0';

  /// Defaults the terminal's fg color without altering the bg.
  static const String FgReset = '39';

  /// Defaults the terminal's bg color without altering the fg.
  static const String BgReset = '49';

  // emmit this code followed by a color code to set the fg color
  static const String FgColor = '38;5;';

// emmit this code followed by a color code to set the fg color
  static const String BgColor = '48;5;';

  /// Colors
  static const AnsiColor Black = AnsiColor(30);
  static const AnsiColor Red = AnsiColor(31);
  static const AnsiColor Green = AnsiColor(32);
  static const AnsiColor Yellow = AnsiColor(33);
  static const AnsiColor Blue = AnsiColor(34);
  static const AnsiColor Magenta = AnsiColor(35);
  static const AnsiColor Cyan = AnsiColor(36);
  static const AnsiColor White = AnsiColor(37);
  static const AnsiColor Orange = AnsiColor(208);
  static AnsiColor Grey({double level = 0.5}) =>
      AnsiColor(232 + (level.clamp(0.0, 1.0) * 23).round());

// passing this as the background color will cause
// the background code to be suppressed resulting
// in the default background color.
  static const AnsiColor none = AnsiColor(-1);
}
