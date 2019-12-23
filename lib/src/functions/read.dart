import 'dart:convert';
import 'dart:io';

import '../util/dshell_exception.dart';
import '../util/progress.dart';

import '../util/stack_trace_impl.dart';
import '../util/waitForEx.dart';

import '../settings.dart';
import 'dshell_function.dart';
import 'is.dart';
import '../util/log.dart';

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

    if (Settings().debug_on) {
      Log.d('read: ${absolute(path)}, delim: ${delim}');
    }

    if (!exists(path)) {
      throw ReadException('The file at ${absolute(path)} does not exists');
    }

    var forEach = Progress.forEach();

    waitForEx<void>(sourceFile
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((line) {
      forEach.addToStdout(line);
    }));

    forEach.close();

    return forEach;
  }

  Progress readStdin({Progress progress}) {
    if (Settings().debug_on) {
      Log.d('readStdin');
    }

    Progress forEach;

    try {
      forEach = progress ?? Progress.forEach();
      String line;

      while ((line = stdin.readLineSync()) != null) {
        forEach.addToStdout(line);
      }
    } finally {
      forEach.close();
    }

    return forEach;
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
