import 'dart:async';

import 'package:async/async.dart';

import '../../dcli.dart';
import 'dev_null.dart';

import 'runnable_process.dart';
import 'wait_for_ex.dart';

/// central class that provides progress information about a running
/// process.
class Progress {
  ///
  Progress(LineAction stdout, {LineAction stderr = devNull})
      : includeStdout = true,
        includeStderr = true {
    _wireStreams(stdout, stderr);
  }

  /// Use this progress to have both stdout and stderr output
  /// suppressed.
  Progress.devNull()
      : includeStdout = true,
        includeStderr = true;

  /// Use this progress to only output data sent to stdout
  Progress.printStdOut()
      : includeStdout = true,
        includeStderr = true {
    _wireStreams(print, devNull);
  }

  /// Use this progress to only output data sent to stderr
  Progress.printStdErr()
      : includeStdout = true,
        includeStderr = true {
    _wireStreams(devNull, print);
  }

  /// Use this progress to print both stdout and stderr
  Progress.print()
      : includeStdout = true,
        includeStderr = true {
    _wireStreams(print, printerr);
  }

  /// EXPERIMENTAL
  ///
  /// Constructs a Progress that provides a stream of all lines written
  /// to stdout and stderr.
  ///
  /// You can take control over whether both stdout and stderr are included
  /// via the named args  [includeStderr] and [includeStdout].
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
  Progress.stream({this.includeStdout = true, this.includeStderr = true}) {
    /// we don't wire the stream but rather allow the user to
    /// obtain the stream directly
  }

  bool _closed = false;

  /// The exist code of the completed process.
  int? exitCode;

  /// TODO: setting [includeStderr] or [includeStdout]
  /// to false stop methods like [toList] from working.
  /// I've not quite got my head around why so for the minute
  /// we only set this settings to false when using [Progress.stream].

  /// If true then lines written to stderr will
  /// be included in the stream.
  final bool includeStderr;

  /// If true then lines written to stdout will
  /// be included in the stream.
  final bool includeStdout;

  final _stdoutCompleter = Completer<bool>();
  final _stderrCompleter = Completer<bool>();

  final _stdoutController = StreamController<String>();
  final _stderrController = StreamController<String>();

  /// Returns a combined stream including stdout and stderr.
  /// You control whether stderr and/or stdout are inserted into the stream when you call
  /// [stream(includeStderr: true, includeStdout)]
  Stream<String> get stream =>
      StreamGroup.merge([_stdoutController.stream, _stderrController.stream]);

  /// adds the [line] to the stdout controller
  void addToStdout(String line) {
    if (!_closed) {
      if (includeStdout) {
        _stdoutController.sink.add(line);
      } else {
        Settings().verbose('addToStdout excluded: line=$line');
      }
    } else {
      Settings().verbose('addToStdout called after stream closed: line=$line');
    }
  }

  /// adds the [line] to the stderr controller
  void addToStderr(String line) {
    if (!_closed) {
      if (includeStderr) {
        _stderrController.sink.add(line);
      } else {
        Settings().verbose('addToStderr excluded: line=$line');
      }
    } else {
      Settings().verbose('addToStderr called after stream closed: line=$line');
    }
  }

  ///
  void forEach(LineAction stdout, {LineAction stderr = devNull}) {
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
  List<String> toList({final int skipLines = 0}) {
    var _skipLines = skipLines;
    final lines = <String>[];

    forEach((line) {
      if (_skipLines > 0) {
        _skipLines--;
      } else {
        lines.add(line);
      }
    }, stderr: (line) {
      if (_skipLines > 0) {
        _skipLines--;
      } else {
        lines.add(line);
      }
    });
    return lines;
  }

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
    _stderrController.close();
    _stdoutController.close();
    _closed = true;
  }

  void onError(RunException error) {
    _stderrController.addError(error);
  }
}
