/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'ansi.dart';

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```dart
/// print(red('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```dart
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
    AnsiColor._apply(
      AnsiColor(AnsiColor.codeRed, bold: bold),
      text,
      background: background,
    );

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```dart
/// print(black('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```dart
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
    AnsiColor._apply(
      AnsiColor(AnsiColor.codeBlack, bold: bold),
      text,
      background: background,
    );

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```dart
/// print(green('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```dart
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
    AnsiColor._apply(
      AnsiColor(AnsiColor.codeGreen, bold: bold),
      text,
      background: background,
    );

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```dart
/// print(blue('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```dart
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
    AnsiColor._apply(
      AnsiColor(AnsiColor.codeBlue, bold: bold),
      text,
      background: background,
    );

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```dart
/// print(yellow('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```dart
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
    AnsiColor._apply(
      AnsiColor(AnsiColor.codeYellow, bold: bold),
      text,
      background: background,
    );

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```dart
/// print(magenta('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```dart
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
    AnsiColor._apply(
      AnsiColor(AnsiColor.codeMagenta, bold: bold),
      text,
      background: background,
    );

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```dart
/// print(cyan('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```dart
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
    AnsiColor._apply(
      AnsiColor(AnsiColor.codeCyan, bold: bold),
      text,
      background: background,
    );

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```dart
/// print(white('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```dart
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
    AnsiColor._apply(
      AnsiColor(AnsiColor.codeWhite, bold: bold),
      text,
      background: background,
    );

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```dart
/// print(orange('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```dart
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
    AnsiColor._apply(
      AnsiColor(AnsiColor.codeOrange, bold: bold),
      text,
      background: background,
    );

/// Wraps the passed text with the ANSI escape sequence for
/// the color red.
/// Use this to control the color of text when printing to the
/// console.
///
/// ```dart
/// print(grey('a dark message'));
/// ```
/// The [text] to wrap.
/// By default the color is [bold] however you can turn off bold
/// by setting the [bold] argment to false:
///
/// ```dart
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
    AnsiColor._apply(
      AnsiColor._grey(level: level, bold: bold),
      text,
      background: background,
    );

/// Helper class to assist in printing text to the console with a color.
///
/// Use one of the color functions instead of this class.
///
/// See:
///  * [black]
///  * [white]
///  * [green]
///  * [orange]
///  ...
class AnsiColor {
  ///
  const AnsiColor(
    int code, {
    bool bold = true,
  })  : _code = code,
        _bold = bold;

  AnsiColor._grey({
    double level = 0.5,
    bool bold = true,
  })  : _code = codeGrey + (level.clamp(0.0, 1.0) * 23).round(),
        _bold = bold;

  /// resets the color scheme.
  static String reset() => _emit(_resetCode);

  /// resets the foreground color
  static String fgReset() => _emit(_fgResetCode);

  /// resets the background color.
  static String bgReset() => _emit(_bgResetCode);

  final int _code;

  final bool _bold;

  //
  static String _emit(String ansicode) => '${Ansi.esc}${ansicode}m';

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
      output = '${_fg(color.code, bold: color.bold)}'
          '${_bg(background.code)}$text$_reset';
    } else {
      output = text;
    }
    return output;
  }

  static String get _reset => '${Ansi.esc}${_resetCode}m';

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
  static const _resetCode = '0';

  /// Defaults the terminal's fg color without altering the bg.
  static const _fgResetCode = '39';

  /// Defaults the terminal's bg color without altering the fg.
  static const _bgResetCode = '49';

  // emit this code followed by a color code to set the fg color
  static const _fgColorCode = '38;5;';

// emit this code followed by a color code to set the fg color
  static const _backgroundCode = '48;5;';

  /// code for black
  static const codeBlack = 30;

  /// code for  red
  static const codeRed = 31;

  /// code for green
  static const codeGreen = 32;

  /// code for yellow
  static const codeYellow = 33;

  /// code for  blue
  static const codeBlue = 34;

  /// code for magenta
  static const codeMagenta = 35;

  /// code for cyan
  static const codeCyan = 36;

  /// code for white
  static const codeWhite = 37;

  /// code for orange
  static const codeOrange = 208;

  /// code for grey
  static const codeGrey = 232;

  /// Colors
  /// black
  static const black = AnsiColor(codeBlack);

  /// red
  static const red = AnsiColor(codeRed);

  /// green
  static const green = AnsiColor(codeGreen);

  /// yellow
  static const yellow = AnsiColor(codeYellow);

  /// blue
  static const blue = AnsiColor(codeBlue);

  /// magenta
  static const magenta = AnsiColor(codeMagenta);

  /// cyan
  static const cyan = AnsiColor(codeCyan);

  /// white
  static const white = AnsiColor(codeWhite);

  /// orange
  static const orange = AnsiColor(codeOrange);

  /// passing this as the background color will cause
  /// the background code to be suppressed resulting
  /// in the default background color.
  static const none = AnsiColor(-1, bold: false);
}
