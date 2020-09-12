import 'ansi.dart';

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(red('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```
/// print(red('a dark message', bold: false));
/// ```
///
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to White.
///
String red(
  String text, {
  AnsiColor bgcolor = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.code_red, bold: bold), text,
        bgcolor: bgcolor);

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(black('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```
/// print(black('a dark message', bold: false));
/// ```
///
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to White.
///
String black(
  String text, {
  AnsiColor bgcolor = AnsiColor.white,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.code_black, bold: bold), text,
        bgcolor: bgcolor);

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(green('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```
/// print(green('a dark message', bold: false));
/// ```
///
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to White.
///
String green(
  String text, {
  AnsiColor bgcolor = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.code_green, bold: bold), text,
        bgcolor: bgcolor);

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(blue('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```
/// print(blue('a dark message', bold: false));
/// ```
///
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to White.
///
String blue(
  String text, {
  AnsiColor bgcolor = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.code_blue, bold: bold), text,
        bgcolor: bgcolor);

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(yellow('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```
/// print(yellow('a dark message', bold: false));
/// ```
///
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to White.
///
String yellow(
  String text, {
  AnsiColor bgcolor = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.code_yellow, bold: bold), text,
        bgcolor: bgcolor);

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(magenta('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```
/// print(magenta('a dark message', bold: false));
/// ```
///
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to White.
///xt.  Defaults to none.
///
String magenta(
  String text, {
  AnsiColor bgcolor = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.code_magenta, bold: bold), text,
        bgcolor: bgcolor);

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(cyan('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```
/// print(cyan('a dark message', bold: false));
/// ```
///
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to White.
///xt.  Defaults to none.
///
String cyan(
  String text, {
  AnsiColor bgcolor = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.code_cyan, bold: bold), text,
        bgcolor: bgcolor);

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(white('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```
/// print(white('a dark message', bold: false));
/// ```
///
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to White.
///xt.  Defaults to none.
///
String white(
  String text, {
  AnsiColor bgcolor = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.code_white, bold: bold), text,
        bgcolor: bgcolor);

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(orange('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```
/// print(orange('a dark message', bold: false));
/// ```
///
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to White.
///xt.  Defaults to none.
///
String orange(
  String text, {
  AnsiColor bgcolor = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.code_orange, bold: bold), text,
        bgcolor: bgcolor);

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```
/// print(grey('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```
/// print(grey('a dark message', bold: false));
/// ```
///
/// [bgcolor] is the background color to use when printing the
/// text.  Defaults to White.
///xt.  Defaults to none.
///
String grey(
  String text, {
  double level = 0.5,
  AnsiColor bgcolor = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor._grey(level: level, bold: bold), text,
        bgcolor: bgcolor);

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

  final bool _bold;

  ///
  const AnsiColor(
    int code, {
    bool bold = true,
  })  : _code = code,
        _bold = bold;

  //
  static String _emit(String ansicode) {
    return '${Ansi.esc}${ansicode}m';
  }

  /// ansi code for this color.
  int get code => _code;

  /// do we bold the color
  bool get bold => _bold;

  /// writes the text to the terminal.
  String apply(String text, {AnsiColor bgcolor = none}) =>
      _apply(this, text, bgcolor: bgcolor);

  static String _apply(
    AnsiColor color,
    String text, {
    AnsiColor bgcolor = none,
  }) {
    String output;

    if (Ansi.isSupported) {
      output =
          '${_fg(color.code, bold: color.bold)}${_bg(bgcolor?.code)}$text$_reset';
    } else {
      output = text;
    }
    return output;
  }

  static String get _reset {
    return '${Ansi.esc}${_resetCode}m';
  }

  static String _fg(
    int code, {
    bool bold = true,
  }) {
    String output;

    if (code == none.code) {
      output = '';
    } else if (code > 39) {
      output = '${Ansi.esc}$_fgColorCode${code}${(bold ? ';1' : '')}m';
    } else {
      output = '${Ansi.esc}${code}${(bold ? ';1' : '')}m';
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

  static const int code_black = 30;
  static const int code_red = 31;
  static const int code_green = 32;
  static const int code_yellow = 33;
  static const int code_blue = 34;
  static const int code_magenta = 35;
  static const int code_cyan = 36;
  static const int code_white = 37;
  static const int code_orange = 208;
  static const int code_grey = 232;

  /// Colors
  static const AnsiColor black = AnsiColor(code_black);
  static const AnsiColor red = AnsiColor(code_red);
  static const AnsiColor green = AnsiColor(code_green);
  static const AnsiColor yellow = AnsiColor(code_yellow);
  static const AnsiColor blue = AnsiColor(code_blue);
  static const AnsiColor magenta = AnsiColor(code_magenta);
  static const AnsiColor cyan = AnsiColor(code_cyan);
  static const AnsiColor white = AnsiColor(code_white);
  static const AnsiColor orange = AnsiColor(code_orange);
  static AnsiColor _grey({
    double level = 0.5,
    bool bold = true,
  }) =>
      AnsiColor(code_grey + (level.clamp(0.0, 1.0) * 23).round(), bold: bold);

  /// passing this as the background color will cause
  /// the background code to be suppressed resulting
  /// in the default background color.
  static const AnsiColor none = AnsiColor(-1, bold: false);
}
