import 'dart:io';

import '../functions/echo.dart';

import 'ansi.dart';

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
enum TerminalClearMode {
  // scrollback,
  /// clear whole screen
  all,

  /// clear screen from the cursor to the bottom of the screen.
  fromCursor,

  /// clear screen from the top of the screen to the cursor
  toCursor
}

/// Provides access to the Ansi Terminal.
class Terminal {
  static final _self = Terminal._internal();

  /// Factory ctor to get a Termainl
  factory Terminal() => _self;

  Terminal._internal();

  /// Returns true if ansi escape characters are supported.
  bool get isAnsi => Ansi.isSupported;

  ///
  void clearScreen({TerminalClearMode mode = TerminalClearMode.all}) {
    //print('clearing screen');
    if (!Ansi.isSupported) return;
    switch (mode) {
      // case AnsiClearMode.scrollback:
      //   echo('${esc}3J', newline: false);
      //   break;

      case TerminalClearMode.all:
        // print('clearing screen');
        echo('${Ansi.esc}2Jm');
        break;
      case TerminalClearMode.fromCursor:
        echo('${Ansi.esc}0Jm');
        break;
      case TerminalClearMode.toCursor:
        echo('${Ansi.esc}1Jm');
        break;
    }
  }

  ///
  void clearLine({TerminalClearMode mode = TerminalClearMode.all}) {
    if (!Ansi.isSupported) return;
    switch (mode) {
      // case AnsiClearMode.scrollback:
      case TerminalClearMode.all:
        echo('\r');
        echo('${Ansi.esc}2K');
        break;
      case TerminalClearMode.fromCursor:
        echo('${Ansi.esc}0K');
        break;
      case TerminalClearMode.toCursor:
        echo('${Ansi.esc}1K');
        break;
    }
  }

  /// Moves the cursor to the start of line.
  // ignore: avoid_setters_without_getters
  void startOfLine() {
    column = 1;
  }

  /// moves the cursor to the given column
  /// 1 is the first column
  // ignore: avoid_setters_without_getters
  set column(int column) {
    echo('${Ansi.esc}${column}G');
  }

  /// Moves the cursor to the start of previous line.
  static void previousLine() {
    echo('${Ansi.esc}0F');
  }

  /// show/hide the cursor
  void showCursor({bool show}) {
    if (show) {
      echo('${Ansi.esc}?25h');
    } else {
      echo('${Ansi.esc}?25l');
    }
  }
}
