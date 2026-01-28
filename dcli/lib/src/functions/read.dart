/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:convert';
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
/// @Throwing(ArgumentError)
/// @Throwing(ReadException)
/// @Throwing(RangeError)
Progress read(String path, {String delim = '\n'}) =>
    _Read().read(path, delim: delim);

/// Read lines from stdin
/// @Throwing(FileSystemException)
Progress readStdin() => _Read()._readStdin();

class _Read extends core.DCliFunction {
  /// Throws [ReadException].
  /// @Throwing(ArgumentError)
  /// @Throwing(ReadException)
  /// @Throwing(RangeError)
  Progress read(String path, {String delim = '\n', Progress? progress}) {
    verbose(() => 'read: ${truepath(path)}, delim: $delim');

    if (!exists(path)) {
      throw ReadException('The file at ${truepath(path)} does not exists');
    }

    progress ??= Progress.capture();

    core.LineFile(path).readAll((line) {
      (progress! as ProgressImpl).addToStdout(utf8.encode('$line\n'));
      return true;
    });
    (progress as ProgressImpl).close();

    return progress;
  }

  /// @Throwing(FileSystemException)
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
  ReadException(super.message, [super.stacktrace]);
}
