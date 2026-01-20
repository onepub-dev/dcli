/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';
import 'internal_progress.dart';

///
/// Returns count [lines] from the end of the file at [path].
///
/// ```dart
/// tail('/var/log/syslog', 10).forEach((line) => print(line));
/// ```
///
/// Throws a [TailException] exception if [path] is not a file.
///
TailProgress tail(String path, int lines) =>
    TailProgress._internal(path, lines);

/// Returned from the [tail] function.
/// The tail function performs no work except to
/// create the [TailProgress]. You call one of the
/// methods on the [TailProgress] to start the tail
/// running.
class TailProgress extends InternalProgress {
  /// Path to the file we will tail.
  String pathTo;

  /// The no. of lines at the end of the file that we
  /// will return.
  int lines;

  TailProgress._internal(this.pathTo, this.lines);

  /// Read lines from the head of the file.
  /// @Throwing(ArgumentError)
  /// @Throwing(core.TailException)
  @override
  void forEach(LineAction action) {
    core.tail(pathTo, lines).forEach(action);
  }
}

/// thrown when the [tail] function encounters an exception
class TailException extends core.DCliFunctionException {
  /// thrown when the [tail] function encounters an exception
  TailException(super.message);
}
