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
/// [background] is the background color to use when printing the
/// text.  Defaults to White.
///
String red(
  String text, {
  AnsiColor background = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.codeRed, bold: bold), text,
        background: background);

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
/// [background] is the background color to use when printing the
/// text.  Defaults to White.
///
String black(
  String text, {
  AnsiColor background = AnsiColor.white,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.codeBlack, bold: bold), text,
        background: background);

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
/// [background] is the background color to use when printing the
/// text.  Defaults to White.
///
String green(
  String text, {
  AnsiColor background = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.codeGeen, bold: bold), text,
        background: background);

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
/// [background] is the background color to use when printing the
/// text.  Defaults to White.
///
String blue(
  String text, {
  AnsiColor background = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.codeBlue, bold: bold), text,
        background: background);

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
/// [background] is the background color to use when printing the
/// text.  Defaults to White.
///
String yellow(
  String text, {
  AnsiColor background = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.codeYellow, bold: bold), text,
        background: background);

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
/// [background] is the background color to use when printing the
/// text.  Defaults to White.
///xt.  Defaults to none.
///
String magenta(
  String text, {
  AnsiColor background = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.codeMagenta, bold: bold), text,
        background: background);

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
/// [background] is the background color to use when printing the
/// text.  Defaults to White.
///xt.  Defaults to none.
///
String cyan(
  String text, {
  AnsiColor background = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.codeCyan, bold: bold), text,
        background: background);

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
/// [background] is the background color to use when printing the
/// text.  Defaults to White.
///xt.  Defaults to none.
///
String white(
  String text, {
  AnsiColor background = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.codeWhite, bold: bold), text,
        background: background);

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
/// [background] is the background color to use when printing the
/// text.  Defaults to White.
///xt.  Defaults to none.
///
String orange(
  String text, {
  AnsiColor background = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor(AnsiColor.codeOrange, bold: bold), text,
        background: background);

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
/// [background] is the background color to use when printing the
/// text.  Defaults to White.
///xt.  Defaults to none.
///
String grey(
  String text, {
  double level = 0.5,
  AnsiColor background = AnsiColor.none,
  bool bold = true,
}) =>
    AnsiColor._apply(AnsiColor._grey(level: level, bold: bold), text,
        background: background);

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
  String apply(String text, {AnsiColor background = none}) =>
      _apply(this, text, background: background);

  static String _apply(
    AnsiColor color,
    String text, {
    AnsiColor background = none,
  }) {
    String? output;

    if (Ansi.isSupported) {
      output =
          '${_fg(color.code, bold: color.bold)}${_bg(background.code)}$text$_reset';
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
      output = '${Ansi.esc}$_fgColorCode$code${bold ? ';1' : ''}m';
    } else {
      output = '${Ansi.esc}$code${bold ? ';1' : ''}m';
    }
    return output;
  }

  // background colors are fg color + 10
  static String _bg(int code) {
    String output;

    if (code == none.code) {
      output = '';
    } else if (code > 49) {
      output = '${Ansi.esc}$_backgroundCode${code + 10}m';
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
  static const String _backgroundCode = '48;5;';

  static const int codeBlack = 30;
  static const int codeRed = 31;
  static const int codeGeen = 32;
  static const int codeYellow = 33;
  static const int codeBlue = 34;
  static const int codeMagenta = 35;
  static const int codeCyan = 36;
  static const int codeWhite = 37;
  static const int codeOrange = 208;
  static const int codeGrey = 232;

  /// Colors
  static const AnsiColor black = AnsiColor(codeBlack);
  static const AnsiColor red = AnsiColor(codeRed);
  static const AnsiColor green = AnsiColor(codeGeen);
  static const AnsiColor yellow = AnsiColor(codeYellow);
  static const AnsiColor blue = AnsiColor(codeBlue);
  static const AnsiColor magenta = AnsiColor(codeMagenta);
  static const AnsiColor cyan = AnsiColor(codeCyan);
  static const AnsiColor white = AnsiColor(codeWhite);
  static const AnsiColor orange = AnsiColor(codeOrange);
  AnsiColor._grey({
    double level = 0.5,
    bool bold = true,
  })  : _code = codeGrey + (level.clamp(0.0, 1.0) * 23).round(),
        _bold = bold;

  /// passing this as the background color will cause
  /// the background code to be suppressed resulting
  /// in the default background color.
  static const AnsiColor none = AnsiColor(-1, bold: false);
}
