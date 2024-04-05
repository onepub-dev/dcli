/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';

import '../../dcli.dart';
import 'progress_impl.dart';
import 'progress_line_splitter.dart';
import 'progress_mixin.dart';

/// Prints stderr, suppresses all other output.
class ProgressStdErrImpl extends ProgressImpl
    with ProgressMixin
    implements ProgressStdErr {
  /// Use this progress to only output data sent to stderr.
  /// If [capture] is true (defaults to false) the output to
  /// stderr is also captured and will be available
  /// in [lines] once the process completes.
  ProgressStdErrImpl({bool capture = false})
      : _capture = capture,
        _controller = StreamController<String>() {
    sink = _controller.sink;
  }

  final bool _capture;

  final _capturedData = <int>[];

  List<String>? _lines;

  @override
  List<String> get lines => _lines ?? ProgressLineSplitter(_capturedData).lines;

  @override
  void addToStderr(List<int> data) {
    for (final line in ProgressLineSplitter(data).lines) {
      print(line);
    }
    if (_capture) {
      _capturedData.addAll(data);
    }
  }

  // final controller = StreamController<String>();
  final StreamController<String> _controller;

  late final Sink<String> sink;

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
    // NOOP
  }
}

abstract class ProgressStdErr implements Progress {
  @override
  List<String> get lines;
}
