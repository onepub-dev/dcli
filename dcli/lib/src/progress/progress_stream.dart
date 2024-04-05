/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';
import 'dart:convert';

import '../../dcli.dart';
import 'progress_impl.dart';
import 'progress_mixin.dart';

/// Prints stderr, suppresses all other output.
class ProgressStreamImpl extends ProgressImpl
    with ProgressMixin
    implements ProgressStdErr {
  /// Use this progress to only output data sent to stderr.
  /// If [capture] is true (defaults to false) the output to
  /// stderr is also captured and will be available
  /// in [lines] once the process completes.
  ProgressStreamImpl({bool includeStderr = false})
      : _controller = StreamController<List<int>>(),
        _includeStderr = includeStderr {
    sink = _controller.sink;
  }

  final bool _includeStderr;
  @override
  final lines = <String>[];

  // final controller = StreamController<String>();
  final StreamController<List<int>> _controller;

  late final Sink<List<int>> sink;

  @override
  Stream<List<int>> get stream => _controller.stream;

  void _addToStream(List<int> line) {
    sink.add(line);
  }

// _LineSplitter  splitter = _LineSplitter();
  //     const LineSplitter().startChunkedConversion(_CallbackSink(lines.add));
  // late final decoder = const Utf8Decoder().startChunkedConversion(splitter);

  @override
  Future<void> forEach(LineAction action) async {
    final transformed = _controller.stream
        .map(String.fromCharCodes)
        .transform(const LineSplitter());

    await transformed.forEach((line) => action(line));
  }

  @override
  void addToStderr(List<int> data) {
    if (_includeStderr) {
      _addToStream(data);
    }
  }

  @override
  void addToStdout(List<int> data) {
    _addToStream(data);
  }

  @override
  void close() {
    print('closing sink');
    sink.close();
  }
}

abstract class ProgressStdErr implements Progress {
  @override
  List<String> get lines;
}
