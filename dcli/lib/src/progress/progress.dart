/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:convert';

import '../../dcli.dart';
import 'progress_both.dart';
import 'progress_dev_null.dart';
import 'progress_std_err.dart';
import 'progress_std_out.dart';
import 'progress_stream.dart';

/// central class that provides progress information about a running
/// process.
abstract class Progress {
  /// Creates a Progress that allows you to individually control what
  /// output is sent to each of the [LineAction]s and what is captured
  /// to the [lines] array.
  /// You must provide a stdout [LineAction] but  stderr are sent to [devNull]
  /// unless you pass a [stderr] [LineAction]
  /// By default no output is captured to the [lines] array unless you
  /// set [captureStdout] or [captureStderr] to true.
  /// Use [encoding] to control how output bytes are decoded into strings.
  factory Progress(LineAction stdout,
          {LineAction stderr = devNull,
          bool captureStdout = false,
          bool captureStderr = false,
          Encoding encoding = utf8}) =>
      ProgressBothImpl(stdout,
          stderr: stderr,
          captureStdout: captureStdout,
          captureStderr: captureStderr,
          encoding: encoding);

  /// Use this progress to print both stdout and stderr.
  /// If [capture] is true (defaults to false) the output to
  /// stdout and stderr is also captured and will be available
  /// in [lines] once the process completes.
  /// Use [encoding] to control how output bytes are decoded into strings.
  factory Progress.print({bool capture = false, Encoding encoding = utf8}) =>
      ProgressBothImpl(print,
          stderr: print,
          captureStdout: capture,
          captureStderr: capture,
          encoding: encoding);

  /// redirect both stdout and stderr to the same [LineAction]
  /// Note: to capture stderr you must pass 'throws: false' to 
  /// the start process method.
  /// Use [encoding] to control how output bytes are decoded into strings.
  factory Progress.both(LineAction both, {Encoding encoding = utf8}) =>
      ProgressBothImpl(both, stderr: both, encoding: encoding);

  /// Captures the output of the called process to a list which
  /// can be obtained by calling [Progress.lines] once
  /// the process completes.
  /// By default both stdout and stderr are captured.
  /// Set [captureStdout] to false to suppress capturing of stdout.
  /// Set [captureStderr] to false to suppress capturing of stderr.
  /// Use [encoding] to control how output bytes are decoded into strings.
  factory Progress.capture(
          {bool captureStdout = true,
          bool captureStderr = true,
          Encoding encoding = utf8}) =>
      ProgressBothImpl(devNull,
          captureStdout: captureStdout,
          captureStderr: captureStderr,
          encoding: encoding);

  /// Use this progress to have both stdout and stderr output
  /// suppressed.
  /// Use [encoding] to control how output bytes are decoded into strings.
  factory Progress.devNull({Encoding encoding = utf8}) =>
      ProgressDevNullImpl(encoding: encoding);

  /// Use this progress to only output data sent to stderr.
  /// If [capture] is true (defaults to false) the output to
  /// stderr is also captured and will be available
  /// in [lines] once the process completes.
  /// Use [encoding] to control how output bytes are decoded into strings.
  factory Progress.printStdErr(
          {bool capture = false, Encoding encoding = utf8}) =>
      ProgressStdErrImpl(capture: capture, encoding: encoding);

  /// Use this progress to only output data sent to stdout.
  /// If [capture] is true (defaults to false) the output to
  /// stdout is also captured and will be available
  /// in [lines] once the process completes.
  /// Use [encoding] to control how output bytes are decoded into strings.
  factory Progress.printStdOut(
          {bool capture = false, Encoding encoding = utf8}) =>
      ProgressStdOutImpl(capture: capture, encoding: encoding);

  factory Progress.stream(
          {bool includeStderr = false, Encoding encoding = utf8}) =>
      ProgressStreamImpl(includeStderr: includeStderr, encoding: encoding);

  int? get exitCode;

  List<String> get lines;

  Stream<List<int>> get stream;

  /// Returns the first line from the command or
  /// null if no lines where generated
  String? get firstLine;

// TODO(bsutton): use this code to turn int list into strings
// when user calls toList.
// late final splitter =
//       const LineSplitter().startChunkedConversion(_CallbackSink(lines.add));
//   late final decoder = const Utf8Decoder().startChunkedConversion(splitter);
  List<String> toList();

  void forEach(void Function(String line) print);

  String toParagraph();
}
