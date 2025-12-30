/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:convert';

import '../../dcli.dart';
import 'progress_impl.dart';
import 'progress_mixin.dart';

/// Creates a Progress that allows you to individually control
/// each aspect of how the [Progress] prints and captures output
/// to stdout and stderr. It usually easier to use one of the
/// pre-package [Progress] constructors such as [Progress.print].
/// If you pass true to either capture argument then all
/// captured lines are written to a single [lines] array
/// in the order they are captured.
class ProgressBothImpl extends ProgressImpl
    with ProgressMixin
    implements ProgressBoth {
  final LineAction _stdout;

  final LineAction _stderr;

  final bool captureStdout;

  final bool captureStderr;

  late final ProgressiveLineSplitter _stdoutSplitter;

  late final ProgressiveLineSplitter _stderrSplitter;

  final _capturedLines = <String>[];

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
      this.captureStderr = false,
      Encoding encoding = utf8})
      : _stderr = stderr,
        super(encoding: encoding) {
    _stdoutSplitter = ProgressiveLineSplitter(encoding: encoding);
    _stderrSplitter = ProgressiveLineSplitter(encoding: encoding);

    _stdoutSplitter.onLine((line) {
      _stdout(line);
      if (captureStdout) {
        _capturedLines.add(line);
      }
    });

    _stderrSplitter.onLine((line) {
      _stderr(line);
      if (captureStderr) {
        _capturedLines.add(line);
      }
    });
  }

  @override
  List<String> get lines => _capturedLines;

  @override
  void addToStdout(List<int> data) {
    _stdoutSplitter.addData(data);
  }

  @override
  void addToStderr(List<int> data) {
    _stderrSplitter.addData(data);
  }

  @override
  List<String> toList() => lines;

  @override
  void close() {
    _stdoutSplitter.close();
    _stderrSplitter.close();
  }
}

abstract class ProgressBoth implements Progress {
  @override
  List<String> get lines;
}

class ProgressiveLineSplitter {
  late final _ProgressLineSink _lineSink;

  late final Sink<String> _lineSplitterSink;

  late final Sink<List<int>> _byteSink;

  ProgressiveLineSplitter({Encoding encoding = utf8}) {
    _lineSink = _ProgressLineSink();
    _lineSplitterSink = const LineSplitter().startChunkedConversion(_lineSink);
    _byteSink = encoding.decoder.startChunkedConversion(_lineSplitterSink);
  }

  void addData(List<int> intList) {
    _byteSink.add(intList);
  }

  void close() {
    _byteSink.close();
    _lineSink.close();
    _lineSplitterSink.close();
  }

  // would break backwards compatibility
  // ignore: use_setters_to_change_properties
  void onLine(void Function(String line) action) {
    _lineSink.action = action;
  }
}

class _ProgressLineSink implements Sink<String> {
  void Function(String line)? action;

  @override
  void add(String data) {
    action?.call(data);
  }

  @override
  void close() {}
}
