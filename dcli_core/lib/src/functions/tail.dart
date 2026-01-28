/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:circular_buffer/circular_buffer.dart';

import '../settings.dart';
import '../util/line_file.dart';
import '../util/truepath.dart';
import 'dcli_function.dart';
import 'is.dart';

///
/// Returns count [lines] from the end of the file at [path].
///
/// ```dart
/// tail('/var/log/syslog', 10).forEach((line) => print(line));
/// ```
///
/// Throws a [TailException] exception if [path] is not a file.
///
List<String> tail(String path, int lines) => _Tail().tail(path, lines);

class _Tail extends DCliFunction {
  /// @Throwing(TailException)
  List<String> tail(
    String path,
    int lines,
  ) {
    verbose(() => 'tail ${truepath(path)} lines: $lines');

    if (lines < 1) {
      throw TailException('lines must be >= 1');
    }

    if (!exists(path)) {
      throw TailException('The path ${truepath(path)} does not exist.');
    }

    if (!isFile(path)) {
      throw TailException('The path ${truepath(path)} is not a file.');
    }

    /// circbuffer requires a min size of 2 so we
    /// add one to make certain it is always greater than one
    /// and then adjust later.
    final buffer = CircularBuffer<String>(lines + 1);
    try {
      withOpenLineFile(path, (file) {
        file.readAll((line) {
          buffer.add(line);
          return true;
        });
      });
    } catch (e) {
      throw TailException(
        'An error occured reading ${truepath(path)}. Error: $e',
      );
    }

    final lastLines = buffer.toList();

    /// adjust the buffer by stripping extra line.
    if (buffer.isFilled) {
      lastLines.removeAt(0);
    }

    return lastLines;
  }
}

/// thrown when the [tail] function encounters an exception
class TailException extends DCliFunctionException {
  /// thrown when the [tail] function encounters an exception
  TailException(super.message);
}
