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
/// Prepares to read count [lines] from the file at [path].
///
/// The [head] function returns a [HeadProgress] which can
/// then be used to read the configured lines via one of [HeadProgress]
/// methods.
///
/// ```dart
/// head('/var/log/syslog', 10).forEach((line) => print(line));
/// ```
///
/// Throws a [core.HeadException] exception if [path] is not a file.
///
HeadProgress head(String path, int lines) =>
    HeadProgress._internal(path, lines);

/// Used to access output from the head command.
///
class HeadProgress extends InternalProgress {
  final String _path;

  final int _lines;

  HeadProgress._internal(this._path, this._lines);

  /// Read lines from the head of the file.
  @override
  void forEach(LineAction action) {
    core.head(_path, _lines).forEach(action);
  }
}
