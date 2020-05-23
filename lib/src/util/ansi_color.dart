import 'dart:io';

import '../functions/echo.dart';

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

///
/// Modes available when clearing a screen or line.
///
/// When used with clearScreen:
/// [all] - clears the entire screen
/// [fromCursor] - clears from the cursor until the end of the screen
/// [toCursor] - clears from the start of the screen to the cursor.
///
///  When used with clearLine:
/// [all] - clears the entire line
/// [fromCursor] - clears from the cursor until the end of the line.
/// [toCursor] - clears from the start of the line to the cursor.
///
enum AnsiClearMode {
  // scrollback,
  /// clear whole screen
  all,

  /// clear screen from the cursor to the bottom of the screen.
  fromCursor,

  /// clear screen from the top of the screen to the cursor
  toCursor
}

///
void clearScreen({AnsiClearMode mode = AnsiClearMode.all}) =>
    AnsiColor.clearScreen(mode);

///
void clearLine({AnsiClearMode mode = AnsiClearMode.all}) =>
    AnsiColor.clearLine(mode);

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
  static bool _emitAnsi;

  /// returns true of the terminal supports ansi escape characters.
  static bool get emitAnsi {
    if (_emitAnsi == null) {
      return stdin.supportsAnsiEscapes;
    } else {
      return _emitAnsi;
    }
  }

  /// You can set [emitAnsi] to
  /// override the detected ansi settings.
  /// Dart doesn't do a great job of correctly detecting
  /// ansi support so this give a way to override it.
  /// If [emitAnsi] is true then escape charaters are emmitted
  /// If [emitAnsi] is false escape characters are not emmited
  /// By default the detected setting is used.
  /// After setting emitAnsi you can reset back to the
  /// default detected by calling [resetEmitAnsi].
  static set emitAnsi(bool emit) => _emitAnsi = emit;

  /// If you have called [emitAnsi] then calling
  /// [resetEmitAnsi]  will reset the emit
  /// setting to the default detected.
  static void get resetEmitAnsi => _emitAnsi = null;

  /// resets the color scheme.
  static String reset() => _emit(_resetCode);

  /// resets the foreground color
  static String fgReset() => _emit(_fgResetCode);

  /// resets the background color.
  static String bgReset() => _emit(_bgResetCode);

  final int _code;

  ///
  const AnsiColor(int code) : _code = code;

  /// ansi code for this color.
  int get code => _code;

  /// writes the text to the terminal.
  String apply(String text, {AnsiColor bgcolor = none}) =>
      _apply(this, text, bgcolor: bgcolor);

  static String _apply(AnsiColor color, String text,
      {AnsiColor bgcolor = none}) {
    String output;

    if (emitAnsi) {
      output = '${_fg(color.code)}${_bg(bgcolor?.code)}$text$_reset';
    } else {
      output = text;
    }
    return output;
  }

  static String get _reset {
    return '$esc${_resetCode}m';
  }

  static String _fg(int code) {
    String output;

    if (code == none.code) {
      output = '';
    } else if (code > 39) {
      output = '$esc$_fgColorCode${code}m';
    } else {
      output = '$esc${code}m';
    }
    return output;
  }

  ///
  static void clearScreen(AnsiClearMode mode) {
    if (!emitAnsi) return;
    switch (mode) {
      // case AnsiClearMode.scrollback:
      //   echo('${esc}3J', newline: false);
      //   break;
      case AnsiClearMode.all:
        echo('${esc}2J', newline: false);
        break;
      case AnsiClearMode.fromCursor:
        echo('${esc}0J', newline: false);
        break;
      case AnsiClearMode.toCursor:
        echo('${esc}1J', newline: false);
        break;
    }
  }

  ///
  static void clearLine(AnsiClearMode mode) {
    if (!emitAnsi) return;
    switch (mode) {
      // case AnsiClearMode.scrollback:
      case AnsiClearMode.all:
        echo(_emit('2K'), newline: false);
        break;
      case AnsiClearMode.fromCursor:
        echo(_emit('0K'), newline: false);
        break;
      case AnsiClearMode.toCursor:
        echo(_emit('1K'), newline: false);
        break;
    }
  }

  // background colors are fg color + 10
  static String _bg(int code) {
    String output;

    if (code == none.code) {
      output = '';
    } else if (code > 49) {
      output = '$esc$_bgColorCode${code + 10}m';
    } else {
      output = '$esc${code + 10}m';
    }
    return output;
  }

  static String _emit(String ansicode) {
    return '$esc${ansicode}m';
  }

  /// ANSI Control Sequence Introducer, signals the terminal for new settings.
  static const esc = '\x1B[';
  // static const esc = '\u001b[';

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
