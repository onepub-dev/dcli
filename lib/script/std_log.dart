import 'dart:io' as io;

import '../settings.dart';
import 'command_line_runner.dart';

enum LogLevel { verbose, normal }

class StdLog {
  static void stdout(String message, {LogLevel level = LogLevel.normal}) {
    if (level == LogLevel.normal ||
        (level == LogLevel.verbose && CommandLineRunner().isVerbose)) {
      io.stdout.writeln("${Settings().appname}: $message");
    }
  }

  static void stderr(String message, [LogLevel level = LogLevel.normal]) {
    if (level == LogLevel.normal ||
        (level == LogLevel.verbose && CommandLineRunner().isVerbose)) {
      io.stderr.writeln("${Settings().appname}: $message");
      // stderr.flush();
    }
  }
}
