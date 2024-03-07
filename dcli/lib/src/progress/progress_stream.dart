/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';

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
      : _controller = StreamController<String>(),
        _includeStderr = includeStderr {
    sink = _controller.sink;
  }

  final bool _includeStderr;
  @override
  final lines = <String>[];

  // final controller = StreamController<String>();
  final StreamController<String> _controller;

  late final Sink<String> sink;

  @override
  Stream<String> get stream => _controller.stream;

  void _addToStream(String line) {
    sink.add(line);
  }

  @override
  void forEach(LineAction action) {
    _controller.stream.listen((line) => action(line));
  }

  @override
  void addToStderr(String line) {
    if (_includeStderr) {
      _addToStream(line);
    }
  }

  @override
  void addToStdout(String line) {
    _addToStream(line);
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
