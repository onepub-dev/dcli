import 'dart:convert';
import 'dart:io';

import '../../dcli_core.dart';
import '../util/logging.dart';

/// Prints the contents of the file located at [path] to stdout.
///
/// ```dart
/// cat("/var/log/syslog");
/// ```
///
/// If the file does not exists then a CatException is thrown.
///
Future<void> cat(String path, {LineAction stdout = print}) async =>
    Cat().cat(path, stdout: stdout);

/// Class for the [cat] function.
class Cat extends DCliFunction {
  /// implementation for the [cat] function.
  Future<void> cat(String path, {LineAction stdout = print}) async {
    final sourceFile = File(path);

    verbose(() => 'cat:  ${truepath(path)}');

    if (!exists(path)) {
      throw CatException('The file at ${truepath(path)} does not exists');
    }

    await sourceFile
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
      stdout(line);
    });
  }
}

/// Thrown if the [cat] function encouters an error.
class CatException extends DCliFunctionException {
  /// Thrown if the [cat] function encouters an error.
  CatException(String reason, [StackTraceImpl? stacktrace])
      : super(reason, stacktrace);

  // @override
  // DCliException copyWith(StackTraceImpl stackTrace) =>
  //     CatException(message, stackTrace);
}
