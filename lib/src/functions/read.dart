import 'dart:convert';
import 'dart:io';

import '../util/dshell_exception.dart';
import '../util/progress.dart';

import '../util/stack_trace_impl.dart';
import '../util/wait_for_ex.dart';

import '../settings.dart';
import 'dshell_function.dart';
import 'is.dart';

/// Reads lines from the file at [path].
/// ```dart
/// read('/var/log/syslog').forEach((line) => print(line));
/// ```
///
/// [delim] sets the line delimiter which defaults to newline
///
/// If the file does not exists then a ReadException is thrown.
///
Progress read(String path, {String delim = '\n'}) =>
    Read().read(path, delim: delim);

/// Read lines from stdin
Progress readStdin() => Read().readStdin();

class Read extends DShellFunction {
  Progress read(String path, {String delim, Progress progress}) {
    var sourceFile = File(path);

    Settings().verbose('read: ${absolute(path)}, delim: ${delim}');

    if (!exists(path)) {
      throw ReadException('The file at ${absolute(path)} does not exists');
    }

    progress ??= Progress.devNull();

    waitForEx<void>(sourceFile
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((line) {
      progress.addToStdout(line);
    }));

    progress.close();

    return progress;
  }

  Progress readStdin({Progress progress}) {
      Settings().verbose('readStdin');

    try {
      progress ??= Progress.devNull();
      String line;

      while ((line = stdin.readLineSync()) != null) {
        progress.addToStdout(line);
      }
    } finally {
      progress.close();
    }

    return progress;
  }
}

class ReadException extends DShellFunctionException {
  ReadException(String reason, [StackTraceImpl stacktrace])
      : super(reason, stacktrace);

  @override
  DShellException copyWith(StackTraceImpl stackTrace) {
    return ReadException(message, stackTrace);
  }
}
