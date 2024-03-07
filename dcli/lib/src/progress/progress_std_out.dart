/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'progress.dart';
import 'progress_impl.dart';
import 'progress_mixin.dart';

/// Prints stderr, suppresses all other output.
class ProgressStdOutImpl extends ProgressImpl
    with ProgressMixin
    implements ProgressStdOut {
  /// Use this progress to only output data sent to stderr.
  /// If [capture] is true (defaults to false) the output to
  /// stderr is also captured and will be available
  /// in [lines] once the process completes.
  ProgressStdOutImpl({bool capture = false}) : _capture = capture;

  final bool _capture;

  @override
  final lines = <String>[];

  @override
  void addToStdout(String line) {
    print(line);
    if (_capture) {
      lines.add(line);
    }
  }

  @override
  void addToStderr(String line) {
    /// just dump the data the ground as we act as dev null
    /// for stdout.
  }

  @override
  void close() {
    // NOOP
  }
}

abstract class ProgressStdOut implements Progress {
  @override
  List<String> get lines;
}
