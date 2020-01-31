/// Returns a string wrapped with the selected ansi
/// fg color codes.
String red(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor._Red, text, bgcolor: bgcolor);

///
/// Wraps the passed text with the ANSI escape sequence for
/// the color black.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(black('a dark message'));
/// ```
/// The [text] to wrap.
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to White.
///
String black(String text, {AnsiColor bgcolor = AnsiColor._White}) =>
    AnsiColor._apply(AnsiColor._Black, text, bgcolor: bgcolor);

///
/// Wraps the passed text with the ANSI escape sequence for
/// the color green.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(green('a colourful message'));
/// ```
/// The [text] to wrap.
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to none.
///
String green(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor._Green, text, bgcolor: bgcolor);

///
/// Wraps the passed text with the ANSI escape sequence for
/// the color blue.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(blue('a colourful message'));
/// ```
/// The [text] to wrap.
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to none.
///
String blue(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor._Blue, text, bgcolor: bgcolor);

///
/// Wraps the passed text with the ANSI escape sequence for
/// the color yellow.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(yellow('a colourful message'));
/// ```
/// The [text] to wrap.
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to none.
///
String yellow(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor._Yellow, text, bgcolor: bgcolor);

///
/// Wraps the passed text with the ANSI escape sequence for
/// the color magenta.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(magenta('a colourful message'));
/// ```
/// The [text] to wrap.
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to none.
///
String magenta(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor._Magenta, text, bgcolor: bgcolor);

///
/// Wraps the passed text with the ANSI escape sequence for
/// the color cyan.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(cyan('a colourful message'));
/// ```
/// The [text] to wrap.
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to none.
///
String cyan(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor._Cyan, text, bgcolor: bgcolor);

///
/// Wraps the passed text with the ANSI escape sequence for
/// the color white.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(white('a colourful message'));
/// ```
/// The [text] to wrap.
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to none.
///
String white(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor._White, text, bgcolor: bgcolor);

///
/// Wraps the passed text with the ANSI escape sequence for
/// the color orange.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(orange('a colourful message'));
/// ```
/// The [text] to wrap.
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to none.
///
String orange(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor._Orange, text, bgcolor: bgcolor);

///
/// Wraps the passed text with the ANSI escape sequence for
/// the color grey.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(grey('a colourful message'));
/// ```
/// The [text] to wrap.
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to none.
///
String grey(String text,
        {double level = 0.5, AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor._Grey(level: level), text, bgcolor: bgcolor);

/// Helper class to assist in printing text to the console with a color.
///
/// Use one of the color functions instead of this class.
///
/// See [black]
///     [white]
///     [green]
///     [orange]
///  ...
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
  static const AnsiColor _Black = AnsiColor(30);
  static const AnsiColor _Red = AnsiColor(31);
  static const AnsiColor _Green = AnsiColor(32);
  static const AnsiColor _Yellow = AnsiColor(33);
  static const AnsiColor _Blue = AnsiColor(34);
  static const AnsiColor _Magenta = AnsiColor(35);
  static const AnsiColor _Cyan = AnsiColor(36);
  static const AnsiColor _White = AnsiColor(37);
  static const AnsiColor _Orange = AnsiColor(208);
  static AnsiColor _Grey({double level = 0.5}) =>
      AnsiColor(232 + (level.clamp(0.0, 1.0) * 23).round());

  /// passing this as the background color will cause
  /// the background code to be suppressed resulting
  /// in the default background color.
  static const AnsiColor none = AnsiColor(-1);
}
