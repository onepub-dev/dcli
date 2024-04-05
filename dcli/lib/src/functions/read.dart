/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';
import '../progress/progress_impl.dart';

/// Reads lines from the file at [path].
/// ```dart
/// read('/var/log/syslog').forEach((line) => print(line));
/// ```
///
/// [delim] sets the line delimiter which defaults to newline
///
/// If the file does not exists then a ReadException is thrown.
///
Progress read(String path, {String delim = '\n'}) =>
    _Read().read(path, delim: delim);

/// Read lines from stdin
Progress readStdin() => _Read()._readStdin();

class _Read extends core.DCliFunction {
  Progress read(String path, {String delim = '\n', Progress? progress}) {
    verbose(() => 'read: ${truepath(path)}, delim: $delim');

    if (!exists(path)) {
      throw ReadException('The file at ${truepath(path)} does not exists');
    }

    progress ??= Progress.capture();

    core.LineFile(path).readAll((line) {
      (progress! as ProgressImpl).addToStdout([...'$line\n'.codeUnits]);
      return true;
    });
    (progress as ProgressImpl).close();

    return progress;
  }

  Progress _readStdin({Progress? progress}) {
    verbose(() => 'readStdin');

    final progressImpl = (progress ?? Progress.devNull()) as ProgressImpl;
    try {
      String? line;

      while ((line = stdin.readLineSync()) != null) {
        progressImpl.addToStdout(line!.codeUnits);
      }
    } finally {
      progressImpl.close();
    }

    return progressImpl as Progress;
  }
}

/// Thrown when the [read] function encouters an error.
class ReadException extends core.DCliFunctionException {
  /// Thrown when the [read] function encouters an error.
  ReadException(super.reason, [super.stacktrace]);
}
