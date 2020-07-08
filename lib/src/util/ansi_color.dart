import 'ansi.dart';

/// Returns a string wrapped with the selected ansi
/// fg color codes.
String red(String text, {AnsiColor bgcolor = AnsiColor.none}) =>
    AnsiColor._apply(AnsiColor._red, text, bgcolor: bgcolor);

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
String black(String text, {AnsiColor bgcolor = AnsiColor._white}) =>
    AnsiColor._apply(AnsiColor._black, text, bgcolor: bgcolor);

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
    AnsiColor._apply(AnsiColor._green, text, bgcolor: bgcolor);

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
    AnsiColor._apply(AnsiColor._blue, text, bgcolor: bgcolor);

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
    AnsiColor._apply(AnsiColor._yellow, text, bgcolor: bgcolor);

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
    AnsiColor._apply(AnsiColor._magenta, text, bgcolor: bgcolor);

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
    AnsiColor._apply(AnsiColor._cyan, text, bgcolor: bgcolor);

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
    AnsiColor._apply(AnsiColor._white, text, bgcolor: bgcolor);

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
    AnsiColor._apply(AnsiColor._orange, text, bgcolor: bgcolor);

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
    AnsiColor._apply(AnsiColor._grey(level: level), text, bgcolor: bgcolor);

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
  /// resets the color scheme.
  static String reset() => _emit(_resetCode);

  /// resets the foreground color
  static String fgReset() => _emit(_fgResetCode);

  /// resets the background color.
  static String bgReset() => _emit(_bgResetCode);

  final int _code;

  ///
  const AnsiColor(int code) : _code = code;

  //
  static String _emit(String ansicode) {
    return '${Ansi.esc}${ansicode}m';
  }

  /// ansi code for this color.
  int get code => _code;

  /// writes the text to the terminal.
  String apply(String text, {AnsiColor bgcolor = none}) =>
      _apply(this, text, bgcolor: bgcolor);

  static String _apply(AnsiColor color, String text,
      {AnsiColor bgcolor = none}) {
    String output;

    if (Ansi.isSupported) {
      output = '${_fg(color.code)}${_bg(bgcolor?.code)}$text$_reset';
    } else {
      output = text;
    }
    return output;
  }

  static String get _reset {
    return '${Ansi.esc}${_resetCode}m';
  }

  static String _fg(int code) {
    String output;

    if (code == none.code) {
      output = '';
    } else if (code > 39) {
      output = '${Ansi.esc}$_fgColorCode${code}m';
    } else {
      output = '${Ansi.esc}${code}m';
    }
    return output;
  }

  // background colors are fg color + 10
  static String _bg(int code) {
    String output;

    if (code == none.code) {
      output = '';
    } else if (code > 49) {
      output = '${Ansi.esc}$_bgColorCode${code + 10}m';
    } else {
      output = '${Ansi.esc}${code + 10}m';
    }
    return output;
  }

  /// Resets

  /// Reset fg and bg colors
  static const String _resetCode = '0';

  /// Defaults the terminal's fg color without altering the bg.
  static const String _fgResetCode = '39';

  /// Defaults the terminal's bg color without altering the fg.
  static const String _bgResetCode = '49';

  // emit this code followed by a color code to set the fg color
  static const String _fgColorCode = '38;5;';

// emit this code followed by a color code to set the fg color
  static const String _bgColorCode = '48;5;';

  /// Colors
  static const AnsiColor _black = AnsiColor(30);
  static const AnsiColor _red = AnsiColor(31);
  static const AnsiColor _green = AnsiColor(32);
  static const AnsiColor _yellow = AnsiColor(33);
  static const AnsiColor _blue = AnsiColor(34);
  static const AnsiColor _magenta = AnsiColor(35);
  static const AnsiColor _cyan = AnsiColor(36);
  static const AnsiColor _white = AnsiColor(37);
  static const AnsiColor _orange = AnsiColor(208);
  static AnsiColor _grey({double level = 0.5}) =>
      AnsiColor(232 + (level.clamp(0.0, 1.0) * 23).round());

  /// passing this as the background color will cause
  /// the background code to be suppressed resulting
  /// in the default background color.
  static const AnsiColor none = AnsiColor(-1);
}
