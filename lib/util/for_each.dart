import 'dart:async';

import 'package:dshell/util/waitForEx.dart';

import 'runnable_process.dart';

class ForEach {
  int _exitCode;

  set exitCode(int exitCode) => _exitCode = exitCode;
  int get exitCode => _exitCode;

  StreamController<String> stdoutController = StreamController();
  StreamController<String> stderrController = StreamController();

  void addToStdout(String line) {
    stdoutController.sink.add(line);
  }

  void addToStderr(String line) {
    stderrController.sink.add(line);
  }

  void forEach(LineAction stdout, {LineAction stderr}) {
    Completer<bool> stdoutCompleter = Completer();
    Completer<bool> stderrCompleter = Completer();

    stdoutController.stream.listen((line) => stdout(line),
        onDone: () => stdoutCompleter.complete(true),
        onError: (Object e, StackTrace s) => stdoutCompleter.completeError(e),
        cancelOnError: true);
    stderrController.stream.listen((line) => stderr(line),
        onDone: () => stderrCompleter.complete(true),
        onError: (Object e, StackTrace s) => stderrCompleter.completeError(e),
        cancelOnError: true);

    // Wait for both streams to complete
    waitForEx(Future.wait([stdoutCompleter.future, stderrCompleter.future]));
  }

  // Returns stdout lines as a list.
  List<String> toList() {
    List<String> lines = List();

    forEach((line) => lines.add(line));
    return lines;
  }

  void close() {
    stderrController.close();
    stdoutController.close();
  }
}
