/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'dart:io';
import 'package:dcli_core/dcli_core.dart' as core;

import 'ansi_color.dart';
import 'terminal.dart';

/// Helper class to assist in printing text to the console with a color.
///
/// Use one of the color functions instead of this class.
///
/// See:
///  * [AnsiColor]
///  * [Terminal]
///  ...
class Ansi {
  /// Factory ctor
  factory Ansi() => _self;

  const Ansi._internal();

  static const _self = Ansi._internal();
  static bool? _emitAnsi;

  /// returns true if stdout supports ansi escape characters.
  static bool get isSupported {
    if (_emitAnsi == null) {
      // We don't trust [stdout.supportsAnsiEscapes] except on Windows.
      // [stdout] relies on the TERM environment variable
      // which generates false negatives.
      if (!core.Settings().isWindows) {
        _emitAnsi = true;
      } else {
        _emitAnsi = stdout.supportsAnsiEscapes;
      }
    }
    return _emitAnsi!;
  }

  /// You can set [isSupported] to
  /// override the detected ansi settings.
  /// Dart doesn't do a great job of correctly detecting
  /// ansi support so this give a way to override it.
  /// If [isSupported] is true then escape charaters are emmitted
  /// If [isSupported] is false escape characters are not emmited
  /// By default the detected setting is used.
  /// After setting emitAnsi you can reset back to the
  /// default detected by calling [resetEmitAnsi].
  static set isSupported(bool emit) => _emitAnsi = emit;

  /// If you have called [isSupported] then calling
  /// [resetEmitAnsi]  will reset the emit
  /// setting to the default detected.
  static void get resetEmitAnsi => _emitAnsi = null;

  /// ANSI Control Sequence Introducer, signals the terminal for new settings.
  static const esc = '\x1b[';
  // static const esc = '\u001b[';

  /// Strip all ansi escape sequences from [line].
  ///
  /// This method is useful when logging messages
  /// or if you need to calculate the number of printable
  /// characters in a message.
  static String strip(String line) =>
      line.replaceAll(RegExp('\x1b\\[[0-9;]+m'), '');
}
