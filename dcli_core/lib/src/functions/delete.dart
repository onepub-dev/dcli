/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import '../../dcli_core.dart';

///
/// Deletes the file at [path].
///
/// If the file does not exists a DeleteException is thrown.
///
/// ```dart
/// delete("/tmp/test.fred", ask: true);
/// ```
///
/// If the [path] is a directory a DeleteException is thrown.
void delete(String path) => _Delete().delete(path);

class _Delete extends DCliFunction {
  void delete(String path) {
    verbose(() => 'delete:  ${truepath(path)}');

    if (!exists(path)) {
      throw DeleteException('The path ${truepath(path)} does not exists.');
    }

    if (isDirectory(path)) {
      throw DeleteException('The path ${truepath(path)} is a directory.');
    }

    try {
      File(path).deleteSync();
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw DeleteException(
        'An error occured deleting ${truepath(path)}. Error: $e',
      );
    }
  }
}

/// Thrown when the [delete] function encounters an error
class DeleteException extends DCliFunctionException {
  /// Thrown when the [delete] function encounters an error
  DeleteException(super.message);
}
