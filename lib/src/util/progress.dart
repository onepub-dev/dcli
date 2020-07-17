import 'dart:async';

import '../../dshell.dart';
import 'dev_null.dart';

import 'runnable_process.dart';
import 'wait_for_ex.dart';

/// central class that provides progress information about a running
/// process.
class Progress {
  bool _closed = false;

  /// The exist code of the completed process.
  int exitCode;

  final _stdoutCompleter = Completer<bool>();
  final _stderrCompleter = Completer<bool>();

  final _stdoutController = StreamController<String>();
  final _stderrController = StreamController<String>();

  ///
  Progress(LineAction stdout, {LineAction stderr = devNull}) {
    stderr ??= devNull;
    _wireStreams(stdout, stderr);
  }

  /// Use this progress to have both stdout and stderr output
  /// suppressed.
  Progress.devNull();

  /// Use this progress to only output data sent to stdout
  Progress.printStdOut() {
    _wireStreams(print, devNull);
  }

  /// Use this progress to only output data sent to stderr
  Progress.printStdErr() {
    _wireStreams(devNull, print);
  }

  /// Use this progress to print both stdout and stderr
  Progress.print() {
    _wireStreams(print, printerr);
  }

  /// adds the [line] to the stdout controller
  void addToStdout(String line) {
    if (!_closed) {
      _stdoutController.sink.add(line);
    } else {
      Settings().verbose('addToStdout called after stream closed: line=$line');
    }
  }

  /// adds the [line] to the stderr controller
  void addToStderr(String line) {
    if (!_closed) {
      _stderrController.sink.add(line);
    } else {
      Settings().verbose('addToStdout called after stream closed: line=$line');
    }
  }

  ///
  void forEach(LineAction stdout, {LineAction stderr = devNull}) {
    stderr ??= devNull;
    _processUntilComplete(stdout, stderr: stderr);
  }

  ///
  /// processes both streams until they complete
  ///
  void _processUntilComplete(LineAction stdout, {LineAction stderr = devNull}) {
    _wireStreams(stdout, stderr);

    // Wait for both streams to complete
    waitForEx(Future.wait([_stdoutCompleter.future, _stderrCompleter.future]));
  }

  ///
  /// processes both streams until they complete
  ///
  void _wireStreams(LineAction stdout, LineAction stderr) {
    assert(stdout != null);
    assert(stderr != null);
    _stdoutController.stream.listen((line) {
      stdout(line);
    },
        onDone: () => _stdoutCompleter.complete(true),
        //ignore: avoid_types_on_closure_parameters
        onError: (Object e, StackTrace s) => _stdoutCompleter.completeError(e),
        cancelOnError: true);

    _stderrController.stream.listen((line) {
      stderr(line);
    },
        onDone: () => _stderrCompleter.complete(true),
        //ignore: avoid_types_on_closure_parameters
        onError: (Object e, StackTrace s) => _stderrCompleter.completeError(e),
        cancelOnError: true);
  }

  /// Returns stdout and stderr lines as a list.
  ///
  /// If you pass a non-zero value to [skipLines]
  /// then the list will skip over the first [skipLines] count;
  /// [skipLines] must be +ve.
  ///
  /// See [firstLine]
  ///     [forEach]
  List<String> toList({int skipLines = 0}) {
    var lines = <String>[];

    forEach((line) {
      if (skipLines > 0) {
        skipLines--;
      } else {
        lines.add(line);
      }
    }, stderr: (line) {
      if (skipLines > 0) {
        skipLines--;
      } else {
        lines.add(line);
      }
    });
    return lines;
  }

  /// Returns the first line from the command or
  /// null if no lines where returned
  String get firstLine {
    String line;
    var lines = toList();
    if (lines.isNotEmpty) {
      line = lines[0];
    }
    return line;
  }

  /// closes the progress.
  void close() {
    _stderrController.close();
    _stdoutController.close();
    _closed = true;
  }
}
