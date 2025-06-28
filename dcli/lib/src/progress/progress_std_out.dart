/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'progress.dart';
import 'progress_both.dart';
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
  ProgressStdOutImpl({bool capture = false}) : _capture = capture {
    _stdoutSplitter.onLine((line) {
      print(line);
      if (_capture) {
        _capturedLines.add(line);
      }
    });
  }

  final _stdoutSplitter = ProgressiveLineSplitter();

  final bool _capture;

  final _capturedLines = <String>[];

  @override
  List<String> get lines => _capturedLines;

  @override
  void addToStdout(List<int> data) {
    _stdoutSplitter.addData(data);
  }

  @override
  void addToStderr(List<int> data) {
    /// just dump the data the ground as we act as dev null
    /// for stdout.
  }

  @override
  void close() {
    _stdoutSplitter.close();
  }
}

abstract class ProgressStdOut implements Progress {
  @override
  List<String> get lines;
}
