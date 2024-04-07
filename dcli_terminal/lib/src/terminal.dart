/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dart_console/dart_console.dart';

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
  /// Factory ctor to get a Terminal
  factory Terminal() => _self;

  // ignore: flutter_style_todos
  /// TODO(bsutton): if we don't have a terminal or ansi isn't supported
  /// we need to suppress any ansi codes being output.

  Terminal._internal();

  static final _self = Terminal._internal();

  final _console = Console();

  /// Returns true if ansi escape characters are supported.
  bool get isAnsi => Ansi.isSupported;

  /// Clears the screen.
  /// If ansi escape sequences are not supported this is a no op.
  /// This call does not update the cursor position so in most
  /// cases you will want to call [home] after calling [clearScreen].
  /// ```dart
  ///  Terminal()
  ///   ..clearScreen()
  ///   ..home();
  /// ```
  void clearScreen({TerminalClearMode mode = TerminalClearMode.all}) {
    switch (mode) {
      // case AnsiClearMode.scrollback:
      //   write('${esc}3J', newline: false);
      //   break;

      case TerminalClearMode.all:
        _console.clearScreen();
        break;
      case TerminalClearMode.fromCursor:
        write('${Ansi.esc}0Jm');
        break;
      case TerminalClearMode.toCursor:
        write('${Ansi.esc}1Jm');
        break;
    }
  }

  /// Clears the current line, moves the cursor to column 0
  /// and then prints [text] effectively overwriting the current
  /// console line.
  /// If the current console doesn't support ansi escape
  /// sequences ([isAnsi] == false) then this call
  /// will simply revert to calling [print].
  void overwriteLine(String text) {
    clearLine();
    column = 0;
    _console.write(text);
  }

  /// Writes [text] to the terminal at the current
  /// cursor location without appending a newline character.
  void write(String text) {
    _console.write(text);
  }

  /// Writes [text] to the console followed by a newline.
  /// You can control the alignment of [text] by passing the optional
  /// [alignment] argument which defaults to left alignment.
  /// The alignment is based on the current terminals width with
  /// spaces inserted to the left of the string to facilitate the alignment.
  /// Make certain the current line is clear and the cursor is at column 0
  /// before calling this method otherwise the alignment will not work
  /// as expected.
  void writeLine(String text, {TextAlignment alignment = TextAlignment.left}) =>
      _console.writeLine(text, alignment);

  /// Clears the current console line without moving the cursor.
  /// If you want to write over the current line then
  /// call [clearLine] followed by [startOfLine] and then
  /// use [write] rather than print as it will leave
  /// the cursor on the current line.
  /// Alternatively use [overwriteLine];
  void clearLine({TerminalClearMode mode = TerminalClearMode.all}) {
    switch (mode) {
      // case AnsiClearMode.scrollback:
      case TerminalClearMode.all:
        _console.eraseLine();
        break;
      case TerminalClearMode.fromCursor:
        _console.eraseCursorToEnd();
        break;
      case TerminalClearMode.toCursor:
        write('${Ansi.esc}1K');
        break;
    }
  }

  /// show/hide the cursor
  void showCursor({required bool show}) {
    if (show) {
      _console.showCursor();
    } else {
      _console.hideCursor();
    }
  }

  /// Moves the cursor to the start of previous line.
  @Deprecated('Use [cursorUp]')
  static void previousLine() {
    Terminal().cursorUp();
  }

  /// Moves the cursor up one row
  void cursorUp() => _console.cursorUp();

  /// Moves the cursor down one row
  void cursorDown() => _console.cursorDown();

  /// Moves the cursor to the left one column
  void cursorLeft() => _console.cursorUp();

  /// Moves the cursor to the right one column
  void cursorRight() => _console.cursorRight();

  /// Returns the column location of the cursor
  int get column => _cursor?.col ?? 0;

  /// moves the cursor to the given column
  /// 0 is the first column
  // ignore: avoid_setters_without_getters
  set column(int column) {
    _console.cursorPosition = Coordinate(row, column);
  }

  /// Moves the cursor to the start of line.
  void startOfLine() {
    column = 0;
  }

  /// The width of the terminal in columns.
  /// Where a column is one character wide.
  /// If no terminal is attached, a value of 80 is returned.
  /// This value can change if the user resizes the console window.
  int get columns {
    if (hasTerminal) {
      return _console.windowWidth;
    } else {
      return 80;
    }
  }

  /// Returns the row location of the cursor.
  /// The first row is row 0.
  int get row => _cursor?.row ?? 24;

  /// moves the cursor to the given row
  /// 0 is the first row
  set row(int row) {
    _console.cursorPosition = Coordinate(row, column);
  }

  /// Returns the current co-ordinates of the cursor.
  /// If no terminal is attached we return null
  /// as attempting to read from from stdin to
  /// obtain the cursor will hang the app.
  Coordinate? get _cursor {
    if (hasTerminal && Ansi.isSupported) {
      try {
        return _console.cursorPosition;
        // ignore: avoid_catching_errors
      } on RangeError catch (_) {
        // if stdin is closed (seems to be within docker)
        // then the call to cursorPosition will fail.
        //   RangeError: Invalid value: Not in inclusive range 0..1114111: -1
        // new String.fromCharCode (dart:core-patch/string_patch.dart:45)
        // Console.cursorPosition (package:dart_console/src/console.dart:304)
        return null;
      }
    } else {
      return null;
    }
  }

  /// Whether a terminal is attached to stdin.
  bool get hasTerminal => stdin.hasTerminal;

  /// The height of the terminal in rows.
  /// Where a row is one character high.
  /// If no terminal is attached to stdout, a [StdoutException] is thrown.
  /// This value can change if the users resizes the console window.
  int get rows {
    if (hasTerminal) {
      return _console.windowHeight;
    } else {
      return 24;
    }
  }

  /// Sets the cursor to the top left corner
  /// of the screen (0,0)
  void home() => _console.resetCursorPosition();

  /// Returns the current console height in rows.
  @Deprecated('Use rows')
  int get lines => rows;
}
