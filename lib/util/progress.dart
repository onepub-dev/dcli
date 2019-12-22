import 'dart:async';

import 'package:dshell/util/waitForEx.dart';

import 'runnable_process.dart';

class Progress {
  int _exitCode;

  set exitCode(int exitCode) => _exitCode = exitCode;
  int get exitCode => _exitCode;

  Completer<bool> stdoutCompleter = Completer();
  Completer<bool> stderrCompleter = Completer();

  StreamController<String> stdoutController = StreamController();
  StreamController<String> stderrController = StreamController();

  Progress(LineAction stdout, {LineAction stderr}) {
    _wireStreams(stdout, stderr: stderr);
  }

  Progress.forEach();

  void addToStdout(String line) {
    stdoutController.sink.add(line);
  }

  void addToStderr(String line) {
    stderrController.sink.add(line);
  }

  void forEach(LineAction stdout, {LineAction stderr}) {
    _processUntilComplete(stdout, stderr: stderr);
  }

  ///
  /// processes both streams until they complete
  ///
  void _processUntilComplete(LineAction stdout, {LineAction stderr}) {
    _wireStreams(stdout, stderr: stderr);

    // Wait for both streams to complete
    waitForEx(Future.wait([stdoutCompleter.future, stderrCompleter.future]));
  }

  ///
  /// processes both streams until they complete
  ///
  void _wireStreams(LineAction stdout, {LineAction stderr}) {
    stdoutController.stream.listen((line) => stdout(line),
        onDone: () => stdoutCompleter.complete(true),
        onError: (Object e, StackTrace s) => stdoutCompleter.completeError(e),
        cancelOnError: true);
    stderrController.stream.listen((line) => stderr(line),
        onDone: () => stderrCompleter.complete(true),
        onError: (Object e, StackTrace s) => stderrCompleter.completeError(e),
        cancelOnError: true);
  }

  // Returns stdout lines as a list.
  List<String> toList() {
    var lines = <String>[];

    forEach((line) => lines.add(line));
    return lines;
  }

  void close() {
    stderrController.close();
    stdoutController.close();
  }
}
