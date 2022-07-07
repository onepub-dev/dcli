/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
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
  HeadProgress._internal(this._path, this._lines);
  final String _path;
  final int _lines;

  /// Read lines from the head of the file.
  @override
  void forEach(LineAction action) {
    waitForEx(
      core
          .head(_path, _lines)
          .then((stream) => stream.listen((line) => action(line))),
    );
  }
}
