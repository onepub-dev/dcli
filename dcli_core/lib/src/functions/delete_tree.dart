/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import '../../dcli_core.dart';

/// Recursively deletes the contents of the directory located at [path]
/// with an optional filter. The directory at [path] is not deleted.
///
///
/// [path] must be a directory and must exist.
///
/// ```dart
/// deleteTree(join(rootPath, 'tmp')));
/// ```
///
/// Pass a filter to control what is deleted. Only files/directories
/// that match the filter will be deleted.
///
/// ```dart
/// deleteTree(join(rootPath, 'tmp')
///   , filter: (type, path) => extension(file) == 'dart');
/// ```
///
/// The [filter] method can also be used to report progress as it
/// is called just before we move a file or directory.
///
/// ```dart
/// deleteTree(join(rootPath, 'tmp')
///   , filter: (entity) {
///   var delete = extension(entity) == 'dart';
///   if (delete) {
///     print('deleting: $file');
///   }
///   return delete;
/// });
/// ```
///
///
/// If an error occurs a [DeleteTreeException] is thrown.
///
/// EXPERIMENTAL
void deleteTree(
  String path, {
  bool Function(FileSystemEntityType type, String file) filter = _deleteAll,
}) =>
    _DeleteTree().deleteTree(
      path,
      filter: filter,
    );

bool _deleteAll(FileSystemEntityType type, String file) => true;

class _DeleteTree extends DCliFunction {
  void deleteTree(
    String path, {
    bool Function(FileSystemEntityType type, String file) filter = _deleteAll,
  }) {
    if (!exists(path)) {
      throw DeleteTreeException(
        'The [path] ${truepath(path)} does not exist.',
      );
    }
    if (!isDirectory(path)) {
      throw DeleteTreeException(
        'The [path]  ${truepath(path)} is not a directory.',
      );
    }

    verbose(() => 'deleteTree called ${truepath(path)}');
    try {
      find('*',
          workingDirectory: path,
          includeHidden: true,
          types: [Find.file, Find.directory, Find.link], progress: (item) {
        _process(item.pathTo, filter, item.type);
        return true;
      });
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw DeleteTreeException(
        'An error occured deleting directory ${truepath(path)}. '
        'Error: $e',
      );
    }
  }

  void _process(
    String pathToFile,
    bool Function(FileSystemEntityType type, String file) filter,
    FileSystemEntityType type,
  ) {
    if (filter(type, pathToFile)) {
      // we create directories as we go.
      // only directories that contain a file that is to be
      // moved will be created.
      // ignore: exhaustive_cases
      switch (type) {
        case FileSystemEntityType.directory:
          {
            deleteDir(pathToFile);
            break;
          }
        case FileSystemEntityType.file:
          {
            delete(pathToFile);
            break;
          }
        case FileSystemEntityType.link:
          {
            deleteSymlink(pathToFile);
            break;
          }
      }

      verbose(
        () => 'deleteTree delting: ${truepath(pathToFile)}',
      );
    }
  }
}

/// Thrown when the [deleteTree] function encouters an error.
class DeleteTreeException extends DCliFunctionException {
  /// Thrown when the [deleteTree] function encouters an error.
  DeleteTreeException(super.message);
}
