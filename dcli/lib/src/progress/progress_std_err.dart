/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:async';

import '../../dcli.dart';
import 'progress_both.dart';
import 'progress_impl.dart';
import 'progress_mixin.dart';

/// Prints stderr, suppresses all other output.
class ProgressStdErrImpl extends ProgressImpl
    with ProgressMixin
    implements ProgressStdErr {
  final _stderrSplitter = ProgressiveLineSplitter();

  final bool _capture;

  final _capturedLines = <String>[];

  // final controller = StreamController<String>();
  final StreamController<String> _controller;

  late final Sink<String> sink;

  /// Use this progress to only output data sent to stderr.
  /// If [capture] is true (defaults to false) the output to
  /// stderr is also captured and will be available
  /// in [lines] once the process completes.
  ProgressStdErrImpl({bool capture = false})
      : _capture = capture,
        _controller = StreamController<String>() {
    sink = _controller.sink;

    _stderrSplitter.onLine((line) {
      print(line);
      if (_capture) {
        _capturedLines.add(line);
      }
    });
  }

  @override
  List<String> get lines => _capturedLines;

  @override
  void addToStderr(List<int> data) {
    _stderrSplitter.addData(data);
  }

  void addToStream(String line) {
    sink.add(line);
  }

  @override
  void forEach(LineAction action) {
    _controller.stream.listen((line) => action(line));
  }

  @override
  void addToStdout(List<int> data) {
    /// just dump the data the ground as we act as dev null
    /// for stdout.
  }

  @override
  void close() {
    _stderrSplitter.close();
  }
}

abstract class ProgressStdErr implements Progress {
  @override
  List<String> get lines;
}
