/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import '../../dcli.dart';
import 'progress_both.dart';
import 'progress_dev_null.dart';
import 'progress_std_err.dart';
import 'progress_std_out.dart';
import 'progress_stream.dart';

/// central class that provides progress information about a running
/// process.
abstract class Progress {
  factory Progress(LineAction stdout,
          {LineAction stderr = devNull,
          bool captureStdout = false,
          bool captureStderr = false}) =>
      ProgressBothImpl(stdout,
          stderr: stderr,
          captureStdout: captureStdout,
          captureStderr: captureStderr);

  /// Use this progress to print both stdout and stderr.
  /// If [capture] is true (defaults to false) the output to
  /// stdout and stderr is also captured and will be available
  /// in [lines] once the process completes.
  factory Progress.print({bool capture = false}) => ProgressBothImpl(print,
      stderr: print, captureStdout: capture, captureStderr: capture);

  /// Captures the output of the called process to a list which
  /// can be obtained by calling [Progress.lines] once
  /// the process completes.
  /// By default both stdout and stderr are captured.
  /// Set [captureStdout] to false to suppress capturing of stdout.
  /// Set [captureStderr] to false to suppress capturing of stderr.
  factory Progress.capture(
          {bool captureStdout = true, bool captureStderr = true}) =>
      ProgressBothImpl(devNull,
          captureStdout: captureStdout, captureStderr: captureStderr);

  /// Use this progress to have both stdout and stderr output
  /// suppressed.
  factory Progress.devNull() => ProgressDevNullImpl();

  /// Use this progress to only output data sent to stderr.
  /// If [capture] is true (defaults to false) the output to
  /// stderr is also captured and will be available
  /// in [lines] once the process completes.
  factory Progress.printStdErr({bool capture = false}) =>
      ProgressStdErrImpl(capture: capture);

  /// Use this progress to only output data sent to stdout.
  /// If [capture] is true (defaults to false) the output to
  /// stdout is also captured and will be available
  /// in [lines] once the process completes.
  factory Progress.printStdOut({bool capture = false}) =>
      ProgressStdOutImpl(capture: capture);

  factory Progress.stream({bool includeStderr = false}) =>
      ProgressStreamImpl(includeStderr: includeStderr);

  int? get exitCode;

  List<String> get lines;

  Stream<List<int>> get stream;

  /// Returns the first line from the command or
  /// null if no lines where generated
  String? get firstLine;

// TODO: use this code to turn int list into strings
// when user calls toList.
// late final splitter =
//       const LineSplitter().startChunkedConversion(_CallbackSink(lines.add));
//   late final decoder = const Utf8Decoder().startChunkedConversion(splitter);
  List<String> toList();

  void forEach(void Function(String line) print);

  String toParagraph();
}
