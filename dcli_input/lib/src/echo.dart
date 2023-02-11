/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
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
Future<void> echo(String text, {bool newline = false}) async =>
    _Echo().echo(text, newline: newline);

class _Echo extends DCliFunction {
  Future<void> echo(String text, {required bool newline}) async {
    if (newline) {
      stdout.writeln(text);
    } else {
      stdout.write(text);
    }
    // ignore: discarded_futures
    await stdout.flush();
  }
}
