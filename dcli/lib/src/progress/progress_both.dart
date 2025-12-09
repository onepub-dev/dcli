/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

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

  final _stdoutSplitter = ProgressiveLineSplitter();

  final _stderrSplitter = ProgressiveLineSplitter();

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
      this.captureStderr = false})
      : _stderr = stderr {
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
  void Function(String line)? action;

  final currentLine = StringBuffer();
  void addData(List<int> intList) {
    var lastWasCR = false;

    for (final value in intList) {
      if (lastWasCR) {
        if (value == '\n'.codeUnitAt(0)) {
          // If last was CR and current is LF, terminate the line
          action?.call(currentLine.toString());
          currentLine.clear();
        } else {
          // If last was CR but current is not LF, add a new line
          action?.call(currentLine.toString());
          currentLine
            ..clear()
            ..writeCharCode(value);
        }
        lastWasCR = false;
      } else {
        if (value == '\r'.codeUnitAt(0)) {
          lastWasCR = true;
        } else if (value == '\n'.codeUnitAt(0)) {
          // If current is LF, terminate the line
          action?.call(currentLine.toString());
          currentLine.clear();
        } else {
          // Otherwise, append the character
          currentLine.writeCharCode(value);
        }
      }
    }
  }

  void close() {
    if (currentLine.isNotEmpty) {
      action?.call(currentLine.toString());
    }
  }

  // would break backwards compatibility
  // ignore: use_setters_to_change_properties
  void onLine(void Function(String line) action) {
    this.action = action;
  }
}
