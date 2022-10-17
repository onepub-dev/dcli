/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:crypto/crypto.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:file/file.dart';

import 'wait_for_ex.dart';

///
///
/// Returns a FileStat instance describing the
/// file or directory located by [path].
///
FileStat stat(String path) => waitForEx(
    // ignore: discarded_futures
    core.stat(path));

/// Returns the length of the file at [pathToFile] in bytes.
int fileLength(String pathToFile) => waitForEx(
    // ignore: discarded_futures
    core.fileLength(pathToFile));

/// Calculates the sha256 hash of a file's
/// content.
///
/// This is likely to be an expensive operation
/// if the file is large.
///
/// You can use this method to check if a file
/// has changes since the last time you took
/// the file's hash.
///
/// Throws [FileNotFoundException] if [path]
/// doesn't exist.
/// Throws [NotAFileException] if path is
/// not a file.
Digest calculateHash(String path) => waitForEx(
  // ignore: discarded_futures
  core.calculateHash(path));

/// Thrown when a file doesn't exist
class FileNotFoundException extends core.DCliException {
  /// Thrown when a file doesn't exist
  FileNotFoundException(String path)
      : super('The file ${core.truepath(path)} does not exist.');
}

/// Thrown when a path is not a file.
class NotAFileException extends core.DCliException {
  /// Thrown when a path is not a file.
  NotAFileException(String path)
      : super('The path ${core.truepath(path)} is not a file.');
}
