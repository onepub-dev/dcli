import 'dart:convert';
import 'dart:io';

import '../settings.dart';
import '../util/dcli_exception.dart';
import '../util/runnable_process.dart';

import '../util/stack_trace_impl.dart';
import '../util/wait_for_ex.dart';

import 'dcli_function.dart';
import 'is.dart';

/// Prints the contents of the file located at [path] to stdout.
///
/// ```dart
/// cat("/var/log/syslog");
/// ```
///
/// If the file does not exists then a CatException is thrown.
///
///
void cat(String path, {LineAction stdout}) => Cat().cat(path, stdout: stdout);

/// Class for the [cat] function.
class Cat extends DCliFunction {
  /// implementation for the [cat] function.
  void cat(String path, {LineAction stdout}) {
    var sourceFile = File(path);

    Settings().verbose('cat:  ${absolute(path)}');

    if (!exists(path)) {
      throw CatException('The file at ${absolute(path)} does not exists');
    }

    waitForEx<void>(sourceFile
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((line) {
      if (stdout != null) {
        stdout(line);
      } else {
        print(line);
      }
    }));
  }
}

/// Thrown if the [cat] function encouters an error.
class CatException extends DCliFunctionException {
  /// Thrown if the [cat] function encouters an error.
  CatException(String reason, [StackTraceImpl stacktrace])
      : super(reason, stacktrace);

  @override
  DCliException copyWith(StackTraceImpl stackTrace) {
    return CatException(message, stackTrace);
  }
}
