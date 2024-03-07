/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import '../../dcli.dart';
import 'progress_impl.dart';
import 'progress_mixin.dart';

/// Prints stderr, suppresses all other output.
class ProgressBothImpl extends ProgressImpl
    with ProgressMixin
    implements ProgressBoth {
  /// Creates a Progress that allows you to individually control
  /// each aspect of how the [Progress] prints and captures output
  /// to stdout and stderr. It usually easier to use one of the
  /// pre-package [Progress] constructors such as [Progress.print].
  /// If you pass true to either capture argument then all
  /// captured lines are written to a single [lines] array
  /// in the order they are captured.
  ProgressBothImpl(this._stdout,
      {LineAction stderr = devNull,
      this.captureStdout = false,
      this.captureStderr = false})
      : _stderr = stderr;

  final LineAction _stdout;
  final LineAction _stderr;
  final bool captureStdout;
  final bool captureStderr;

  @override
  final lines = <String>[];

  @override
  void addToStdout(String line) {
    _stdout(line);
    if (captureStdout) {
      lines.add(line);
    }
  }

  @override
  void addToStderr(String line) {
    _stderr(line);
    if (captureStderr) {
      lines.add(line);
    }
  }

  @override
  List<String> toList() => lines;

  @override
  void close() {
    // NOOP
  }
}

abstract class ProgressBoth implements Progress {
  @override
  List<String> get lines;
}
