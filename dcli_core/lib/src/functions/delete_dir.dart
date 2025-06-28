/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import '../../dcli_core.dart';

///
/// Deletes the directory located at [path].
///
/// If [recursive] is true (default true) then the directory and all child files
/// and directories will be deleted.
///
/// ```dart
/// deleteDir("/tmp/testing", recursive=true);
/// ```
///
/// If [path] is not a directory then a [DeleteDirException] is thrown.
///
/// If the directory does not exists a [DeleteDirException] is thrown.
///
/// If the directory cannot be delete (e.g. permissions) a
/// [DeleteDirException] is thrown.
///
/// If recursive is false the directory must be empty otherwise a
/// [DeleteDirException] is thrown.
///
/// See [isDirectory]
///     [exists]
///
void deleteDir(String path, {bool recursive = true}) =>
    _DeleteDir().deleteDir(path, recursive: recursive);

class _DeleteDir extends DCliFunction {
  void deleteDir(String path, {required bool recursive}) {
    verbose(() => 'deleteDir:  ${truepath(path)} recursive: $recursive');

    if (!exists(path)) {
      throw DeleteDirException('The path ${truepath(path)} does not exist.');
    }

    if (!isDirectory(path)) {
      throw DeleteDirException(
        'The path ${truepath(path)} is not a directory.',
      );
    }

    try {
      Directory(path).deleteSync(recursive: recursive);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw DeleteDirException(
        'Unable to delete the directory ${truepath(path)}. Error: $e',
      );
    }
  }
}

/// Throw when [deleteDir] function encounters an error
class DeleteDirException extends DCliFunctionException {
  /// Throw when [deleteDir] function encounters an error
  DeleteDirException(super.message);
}
