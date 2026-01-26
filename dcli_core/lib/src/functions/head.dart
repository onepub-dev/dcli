/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import '../../dcli_core.dart';

///
/// Returns count [lines] from the file at [path].
///
/// ```dart
/// head('/var/log/syslog', 10).forEach((line) => print(line));
/// ```
///
/// Throws a [HeadException] exception if [path] is not a file.
///
List<String> head(String path, int lines) => _Head().head(path, lines);

class _Head extends DCliFunction {
  List<String> head(
    String path,
    int lines,
  ) {
    verbose(() => 'head ${truepath(path)} lines: $lines');

    if (!exists(path)) {
      throw HeadException('The path ${truepath(path)} does not exist.');
    }

    if (!isFile(path)) {
      throw HeadException('The path ${truepath(path)} is not a file.');
    }

    try {
      return withOpenLineFile(path, (file) {
        final result = <String>[];
        file.readAll((line) {
          result.add(line);
          return result.length < lines;
        });
        return result;
      });
    }
    catch (e) {
      throw HeadException(
        'An error occured reading ${truepath(path)}. Error: $e',
      );
    } finally {}
  }
}

/// Thrown if the [head] function encounters an error.
class HeadException extends DCliFunctionException {
  /// Thrown if the [head] function encounters an error.
  HeadException(super.message);
}
