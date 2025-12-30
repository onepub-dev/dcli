/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:async';
import 'dart:convert';

import '../../dcli.dart';
import 'progress_impl.dart';
import 'progress_mixin.dart';

/// Creates a Progress that streams stdout data and optionally
/// stderr (in a single stream).
class ProgressStreamImpl extends ProgressImpl
    with ProgressMixin
    implements ProgressStdErr {
  final bool _includeStderr;

  @override
  final lines = <String>[];

  // final controller = StreamController<String>();
  final StreamController<List<int>> _controller;

  late final Sink<List<int>> sink;

  ProgressStreamImpl({bool includeStderr = false, super.encoding = utf8})
      : _controller = StreamController<List<int>>(),
        _includeStderr = includeStderr {
    sink = _controller.sink;
  }

  @override
  Stream<List<int>> get stream => _controller.stream;

  void _addToStream(List<int> line) {
    sink.add(line);
  }

  @override
  Future<void> forEach(LineAction action) async {
    final transformed = encoding.decoder
        .bind(_controller.stream)
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
    sink.close();
  }
}

abstract class ProgressStdErr implements Progress {
  @override
  List<String> get lines;
}
