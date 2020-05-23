import 'dart:io' as io;

import '../settings.dart';

/// sets the log level
enum LogLevel {
  ///
  verbose,

  ///
  normal
}

////
class StdLog {
  /// Logs a message to stdout.
  static void stdout(String message, {LogLevel level = LogLevel.normal}) {
    if (level == LogLevel.normal ||
        (level == LogLevel.verbose && Settings().isVerbose)) {
      io.stdout.writeln('${Settings().appname}: $message');
    }
  }

  /// Logs a message to stderr.
  static void stderr(String message, [LogLevel level = LogLevel.normal]) {
    if (level == LogLevel.normal ||
        (level == LogLevel.verbose && Settings().isVerbose)) {
      io.stderr.writeln('${Settings().appname}: $message');
      // stderr.flush();
    }
  }
}
