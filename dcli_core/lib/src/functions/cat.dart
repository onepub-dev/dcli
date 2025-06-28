/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import '../../dcli_core.dart';

/// Prints the contents of the file located at [path] to stdout.
///
/// ```dart
/// cat("/var/log/syslog");
/// ```
///
/// If the file does not exists then a CatException is thrown.
///
void cat(String path, {LineAction stdout = print}) =>
    Cat().cat(path, stdout: stdout);

/// Class for the [cat] function.
class Cat extends DCliFunction {
  /// implementation for the [cat] function.
  void cat(String path, {LineAction stdout = print}) {
    verbose(() => 'cat:  ${truepath(path)}');

    if (!exists(path)) {
      throw CatException('The file at ${truepath(path)} does not exists');
    }

    LineFile(path).readAll((line) {
      stdout(line);
      return true;
    });
  }
}

/// Thrown if the [cat] function encouters an error.
class CatException extends DCliFunctionException {
  /// Thrown if the [cat] function encouters an error.
  CatException(super.message, [super.stacktrace]);
}
