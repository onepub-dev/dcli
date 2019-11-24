import 'dart:io';

import 'args.dart';

enum LogLevel { verbose, normal }

class Log {
  static void log(String message, {LogLevel level = LogLevel.normal}) {
    if (level == LogLevel.normal ||
        (level == LogLevel.verbose && Args().isVerbose)) {
      stdout.writeln("${Args().appname}: $message");
    }
  }

  static void error(String message, [LogLevel level = LogLevel.normal]) {
    if (level == LogLevel.normal ||
        (level == LogLevel.verbose && Args().isVerbose)) {
      stderr.writeln("${Args().appname}: $message");
      // stderr.flush();
    }
  }
}
