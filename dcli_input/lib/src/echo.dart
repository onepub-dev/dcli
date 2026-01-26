/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:dcli_core/dcli_core.dart';

/// Writes [text] to stdout including a newline.
///
/// ```dart
/// echo("Hello world", newline=false);
/// ```
///
/// If [newline] is false then a newline will not be output.
///
/// [newline] defaults to false.
Future<void> echo(String text, {bool newline = false}) =>
    _Echo().echo(text, newline: newline);

class _Echo extends DCliFunction {
  Future<void> echo(String text, {required bool newline}) async {
    if (newline) {
      stdout.writeln(text);
    } else {
      stdout.write(text);
    }
    await stdout.flush();
  }
}
