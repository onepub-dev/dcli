/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
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
    // ignore: avoid_catches_without_on_clauses
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
  HeadException(super.reason);
}
