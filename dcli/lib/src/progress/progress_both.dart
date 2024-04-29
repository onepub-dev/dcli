/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import '../../dcli.dart';
import 'progress_impl.dart';
import 'progress_line_splitter.dart';
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

  final _capturedData = <int>[];

  List<String>? _lines;

  @override
  List<String> get lines => _lines ?? ProgressLineSplitter(_capturedData).lines;

  @override
  void addToStdout(List<int> data) {
    for (final line in ProgressLineSplitter(data).lines) {
      _stdout(line);
      // CONSIDER: we could immediately cache these lines
      // but then we are storing them twice (_capturedData) and _lines.
      // for the moment I've gone with a smaller memory overhead
      // and higher cpu utlisation.
    }

    if (captureStdout) {
      _capturedData.addAll(data);
    }
  }

  @override
  void addToStderr(List<int> data) {
    for (final line in ProgressLineSplitter(data).lines) {
      _stderr(line);
    }
    if (captureStderr) {
      _capturedData.addAll(data);
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

class ProgressiveLineSplitter {
  final lines = <String>[];

  final currentLine = StringBuffer();
  void addData(List<int> intList) {
    var lastWasCR = false;

    for (final value in intList) {
      if (lastWasCR) {
        if (value == '\n'.codeUnitAt(0)) {
          // If last was CR and current is LF, terminate the line
          lines.add(currentLine.toString());
          currentLine.clear();
        } else {
          // If last was CR but current is not LF, add a new line
          lines.add(currentLine.toString());
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
          lines.add(currentLine.toString());
          currentLine.clear();
        } else {
          // Otherwise, append the character
          currentLine.writeCharCode(value);
        }
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine.toString());
    }
  }
}
