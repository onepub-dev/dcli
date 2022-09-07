/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:collection/collection.dart';

import '../../dcli.dart';

/// central class that provides progress information about a running
/// process.
class Progress {
  /// Creates a Progress that allows you to individually control
  /// each aspect of how the [Progress] prints and captures output
  /// to stdout and stderr. It usually easier to use one of the
  /// pre-package [Progress] constructors such as [Progress.print].
  Progress(
    LineAction stdout, {
    LineAction stderr = devNull,
    bool captureStdin = false,
    bool captureStderr = false,
  })  : _includeStdout = stdout != devNull,
        _includeStderr = stderr != devNull,
        _captureStdout = captureStdin,
        _captureStderr = captureStderr {
    _wireStreams(stdout, stderr);
  }

  /// Use this progress to have both stdout and stderr output
  /// suppressed.
  Progress.devNull()
      : _includeStdout = false,
        _includeStderr = false;

  /// Use this progress to only output data sent to stdout.
  /// If [capture] is true (defaults to false) the output to
  /// stdout is also captured and will be available
  /// in [lines] once the process completes.
  Progress.printStdOut({bool capture = false})
      : _includeStdout = true,
        _includeStderr = false,
        _captureStdout = capture {
    _wireStreams(print, devNull);
  }

  /// Use this progress to only output data sent to stderr.
  /// If [capture] is true (defaults to false) the output to
  /// stderr is also captured and will be available
  /// in [lines] once the process completes.
  Progress.printStdErr({bool capture = false})
      : _includeStdout = false,
        _includeStderr = true,
        _captureStderr = capture {
    _wireStreams(devNull, print);
  }

  /// Use this progress to print both stdout and stderr.
  /// If [capture] is true (defaults to false) the output to
  /// stdout and stderr is also captured and will be available
  /// in [lines] once the process completes.
  Progress.print({bool capture = false})
      : _includeStdout = true,
        _includeStderr = true,
        _captureStdout = capture,
        _captureStderr = capture {
    _wireStreams(print, printerr);
  }

  /// Captures the output of the called process to a list which
  /// can be obtained by calling [Progress.lines] once
  /// the process completes.
  /// By default both stdout and stderr are captured.
  /// Set [captureStdout] to false to suppress capturing of stdout.
  /// Set [captureStderr] to false to suppress capturing of stderr.
  Progress.capture({bool captureStdout = true, bool captureStderr = true})
      : _captureStdout = captureStdout,
        _captureStderr = captureStderr,
        _includeStdout = false,
        _includeStderr = false {
    _wireStreams(devNull, devNull);
  }

  /// EXPERIMENTAL
  ///
  /// Constructs a Progress that provides a stream of all lines written
  /// to stdout and stderr.
  ///
  /// You can take control over whether both stdout and stderr are included
  /// via the named args  [includeStderr] and [_includeStdout].
  ///
  /// By default both are set to true.
  ///
  /// Using a stream is one of the few places in dcli that you will need
  /// to use a future. If you don't use a Completer as per the following
  /// example then the stream will output data as the rest of your script
  /// continues to run.
  ///
  ///
  /// ```dart
  ///   var progress = Progress.stream();
  ///   'tail /var/log/syslog'.start(
  ///       progress: progress,
  ///       runInShell: true,
  ///   );
  ///
  ///   /// Use a Completer with onDone and waitForEx to
  ///   /// have your code wait until the stream is drained.
  ///   var done = Completer<void>();
  ///   progress.stream.listen((event) {
  ///       print('stream: $event');
  ///     }).onDone(() => done.complete());
  ///   waitForEx<void>(done.future);
  ///   print('done');
  ///````
  ///
  Progress.stream({bool includeStdout = true, bool includeStderr = true})
      : _includeStdout = includeStdout,
        _includeStderr = includeStderr {
    /// we don't wire the stream but rather allow the user to
    /// obtain the stream directly
  }

  bool _closed = false;

  /// The exist code of the completed process.
  int? exitCode;

  /// If true then lines written to stderr will
  /// be included in the stream.
  bool _includeStderr;

  /// If true then lines written to stdout will
  /// be included in the stream.
  bool _includeStdout;

  final _stdoutCompleter = Completer<bool>();
  final _stderrCompleter = Completer<bool>();

  final _stdoutController = StreamController<String>();
  final _stderrController = StreamController<String>();

  /// If true we store all output to stdout in [_lines]
  bool _captureStdout = false;

  /// If true we store all output to stderr in [_lines]
  bool _captureStderr = false;

  // final List<ProgressLine> _lines = [];
  final List<String> _lines = [];

  /// Returns a combined stream including stdout and stderr.
  /// You control whether stderr and/or stdout are inserted into the stream when you call
  /// [stream(includeStderr: true, includeStdout)]
  Stream<String> get stream =>
      StreamGroup.merge([_stdoutController.stream, _stderrController.stream]);

  /// adds the [line] to the stdout controller
  void addToStdout(String line) {
    if (!_closed) {
      _stdoutController.sink.add(line);
    } else {
      verbose(() => 'addToStdout called after stream closed: line=$line');
    }
  }

  /// adds the [line] to the stderr controller
  void addToStderr(String line) {
    if (!_closed) {
      _stderrController.sink.add(line);
    } else {
      verbose(() => 'addToStderr called after stream closed: line=$line');
    }
  }

  bool _wired = false;

  ///
  /// processes both streams until they complete
  ///
  void _processUntilComplete(LineAction stdout, {LineAction stderr = devNull}) {
    /// We can get wired from one of the constructors
    /// or from here.
    if (!_wired) {
      _wireStreams(stdout, stderr);
    }

    // Wait for both streams to complete
    // ignore: discarded_futures
    waitForEx(Future.wait([_stdoutCompleter.future, _stderrCompleter.future]));
  }

  ///
  /// processes both streams until they complete
  ///
  void _wireStreams(LineAction stdout, LineAction stderr) {
    _wired = true;
    _stdoutController.stream.listen(
      (line) {
        if (_includeStdout) {
          stdout(line);
        }
        //  else {
        //   verbose(() => 'addToStdout excluded: line=$line');
        // }
        if (_captureStdout) {
          _lines.add(line);
        }
      },
      onDone: () => _stdoutCompleter.complete(true),
      //ignore: avoid_types_on_closure_parameters
      onError: (Object e, StackTrace s) => _stdoutCompleter.completeError(e),
      cancelOnError: true,
    );

    _stderrController.stream.listen(
      (line) {
        if (_includeStderr) {
          stderr(line);
        } else {
          verbose(() => 'addToStdout excluded: line=$line');
        }
        if (_captureStderr) {
          _lines.add(line);
        }
      },
      onDone: () => _stderrCompleter.complete(true),
      //ignore: avoid_types_on_closure_parameters
      onError: (Object e, StackTrace s) => _stderrCompleter.completeError(e),
      cancelOnError: true,
    );
  }

  ///
  void forEach(LineAction stdout, {LineAction stderr = devNull}) {
    /// This is somewhat dodgy as we essentially replace the progresses
    /// stdout and stderr handlers that we setup when the
    /// progress was originally created. We need to find
    /// a more self consistent approach as this behavour can endup
    /// with the user getting inconsistent results
    /// e.g. they essentially pass stdout and stderr twice.
    _includeStdout = true;
    if (stderr != devNull) {
      _includeStderr = true;
    }
    _processUntilComplete(stdout, stderr: stderr);
  }

  /// Returns stdout and stderr lines as a list.
  ///
  /// If you pass a non-zero value to [skipLines]
  /// then the list will skip over the first [skipLines] count;
  /// [skipLines] must be +ve.
  ///
  /// See:
  ///  * [firstLine]
  ///  * [toParagraph]
  ///  * [forEach]
  List<String> toList({int skipLines = 0}) {
    var _skipLines = skipLines;

    _captureStdout = true;
    _captureStderr = true;

    _processUntilComplete(devNull);

    final lines = <String>[];

    for (final line in _lines) {
      if (_skipLines > 0) {
        _skipLines--;
      } else {
        lines.add(line);
      }
    }
    return lines;
  }

  /// [toParagraph] runs the contents of this String as a CLI command and
  /// returns the lines written to stdout and stderr as
  /// a single String by join the lines with the platform specific line
  /// delimiter.
  ///
  /// If you pass a non-zero value to [skipLines]
  /// then the list will skip over the first [skipLines] count;
  /// [skipLines] must be +ve.
  ///
  /// See [firstLine]
  ///     [toList]
  ///     [forEach]
  String toParagraph({int skipLines = 0}) =>
      toList(skipLines: skipLines).join(Platform().eol);

  /// If the [Progress] was created with captureStdout = true
  /// or captureStderr = true
  /// then [lines] will contain the captured lines.
  /// If neither capture is true then lines will return an empty list.
  ///
  /// The simpliest way to caputure stdout is to pass in [Progress.capture()].
  ///
  /// ```dart
  /// var lines = start('ls *', progress: Progress.capture()).lines;
  /// ```
  /// An [UnmodifiableListView] of the list is returned.
  List<String> get lines => UnmodifiableListView(_lines);

  /// Returns the first line from the command or
  /// null if no lines where returned
  String? get firstLine {
    String? line;
    final lines = toList();
    if (lines.isNotEmpty) {
      line = lines[0];
    }
    return line;
  }

  /// closes the progress.
  void close() {
    // /// If the stream is never wired
    // /// then we have never listened to the stream.
    // /// [devNull] is an example of a Progress that never
    // /// wires the stream.
    // /// In which case we won't get a done event so the
    // /// completers won't complete.
    // /// So we force them to here.
    // if (!_wired) {
    //   _stdoutCompleter.complete(true);
    //   _stderrCompleter.complete(true);
    // }

    // not certain that unawaitined these calls is correct
    // but awaiting them seems to cause some hangs
    // and the have been unawaited for a long time without
    // any observed problems.
    unawaited(_stderrController.close());
    unawaited(_stdoutController.close());
    _closed = true;
  }

  /// Sends or enqueues an error event.
  void onError(RunException error) {
    _stderrController.addError(error);
  }
}

/// [ProgressWithCapture] is a [Progress] that allows reading [lines]
/// after the process finished whilst allowing you to choose if stdout
/// and stderr is printed.
/// Once the process has completed you can call [lines] to obtain
/// an unmodfiable view of the captured list.
@Deprecated('Use Progress.xxx(captureStdout: true, captureStderr: true)')
class ProgressWithCapture extends Progress {
  /// Use this ctor to capture lines output to stdout and stderr as
  /// well as being able to process the output as it occurs via the [stdout] and
  /// [stdout] [LineAction] parameters.
  /// Call [lines] to obtain the captured output.
  @Deprecated('Use Progress.xxx(captureStdout: true, captureStderr: true)')
  ProgressWithCapture(
    super.stdout, {
    super.stderr,
    bool capture = true,
  }) : super(captureStdin: capture);

  /// Use this [ProgressWithCapture] to have both stdout and stderr output
  /// suppressed whilst capturing all output generated by the process.
  /// Call [lines] to obtain the captured output.
  @Deprecated('Use Progress.xxx(captureStdout: true, captureStderr: true)')
  ProgressWithCapture.devNull()
      : super((line) {}, captureStdin: true, captureStderr: true);

  /// Use this [ProgressWithCapture] to capture and print stdout.
  /// Call [lines] to obtain the captured output.
  @Deprecated('Use Progress.xxx(captureStdout: true, captureStderr: true)')
  ProgressWithCapture.printStdOut({super.capture = true}) : super.printStdOut();

  /// Use this [ProgressWithCapture] to capture and print stderr.
  /// Call [lines] to obtain the captured output.
  @Deprecated('Use Progress.xxx(captureStdout: true, captureStderr: true)')
  ProgressWithCapture.printStdErr({super.capture = true}) : super.printStdErr();

  /// Use this [ProgressWithCapture] to capture and print both stdout
  /// and stderr.
  /// Call [lines] to obtain the captured output.
  @Deprecated('Use Progress.xxx(captureStdout: true, captureStderr: true)')
  ProgressWithCapture.print({super.capture = true}) : super.print();
}

/*
/// Used to store lines captured by a [Progress]
/// Refer to [Progress.lines].
class ProgressLine {
  /// Constructs a [ProgressLine]
  ProgressLine(this.type, this.content, this.lineNo);

  /// The source of the line
  ProgressLineType type;

  /// The contents of the line.
  String content;

  /// The original line no.
  /// The first lineNo is line 1.
  /// If you are using the skipLines option
  /// in the likes of toList then this will
  /// still reflect the original lineNo and is NOT
  /// adjusted to start after skipLines.
  int lineNo;
}

/// The source of the [ProgressLine]
enum ProgressLineType {
  /// The line was capture as the result
  /// of the program sending output to stdout.
  stdout,

  /// The line was capture as the result
  /// of the program sending output to stderr.
  stderr
}
*/
