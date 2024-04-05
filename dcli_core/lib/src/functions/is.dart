/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:stack_trace/stack_trace.dart';

import '../../dcli_core.dart';

// import 'package:posix/posix.dart' as posix;

///
/// Returns true if the given [path] points to a file.
///
/// ```dart
/// isFile("~/fred.jpg");
/// ```
bool isFile(String path) => _Is().isFile(path);

/// Returns true if the given [path] is a directory.
/// ```dart
/// isDirectory("/tmp");
///
/// ```
bool isDirectory(String path) => _Is().isDirectory(path);

/// Returns true if the given [path] is a symlink
///
/// // ```dart
/// isLink("~/fred.jpg");
/// ```
bool isLink(String path) => _Is().isLink(path);

/// Returns true if the given path exists.
/// It may be a file, directory or link.
///
/// If [followLinks] is true (the default) then [exists]
/// will return true if the resolved path exists.
///
/// If [followLinks] is false then [exists] will return
/// true if path exist, whether its a link or not.
///
/// ```dart
/// if (exists("/fred.txt"))
/// ```
///
/// Throws [ArgumentError] if [path] is null or an empty string.
///
/// See [isLink]
///     [isDirectory]
///     [isFile]
bool exists(String path, {bool followLinks = true}) =>
    _Is().exists(path, followLinks: followLinks);

/// Returns the datetime the path was last modified
///
/// [path[ can be either a file or a directory.
///
/// Throws a [DCliException] with a nested
/// [FileSystemException] if the file does not
/// exist or the operation fails.
DateTime lastModified(String path) {
  try {
    return File(path).lastModifiedSync();
  } on FileSystemException catch (e) {
    throw DCliException.from(e, Trace.current());
  }
}

/// Sets the last modified datetime on the given the path.
///
/// [path] can be either a file or a directory.
///
/// Throws a [DCliException] with a nested
/// [FileSystemException] if the file does not
/// exist or the operation fails.

void setLastModifed(String path, DateTime lastModified) {
  try {
    File(path).setLastModifiedSync(lastModified);
  } on FileSystemException catch (e) {
    throw DCliException.from(e, Trace.current());
  }
}

/// Returns true if the passed [pathToDirectory] is an
/// empty directory.
/// For large directories this operation can be expensive.
bool isEmpty(String pathToDirectory) => _Is().isEmpty(pathToDirectory);

class _Is extends DCliFunction {
  bool isFile(String path) {
    final fromType = FileSystemEntity.typeSync(path);
    return fromType == FileSystemEntityType.file;
  }

  /// true if the given path is a directory.
  bool isDirectory(String path) {
    final fromType = FileSystemEntity.typeSync(path);
    return fromType == FileSystemEntityType.directory;
  }

  bool isLink(String path) {
    final fromType = FileSystemEntity.typeSync(path, followLinks: false);
    return fromType == FileSystemEntityType.link;
  }

  /// checks if the given [path] exists.
  ///
  /// Throws [ArgumentError] if [path] is an empty string.
  bool exists(String path, {required bool followLinks}) {
    if (path.isEmpty) {
      throw ArgumentError('path must not be empty.');
    }

    final exists = FileSystemEntity.typeSync(path, followLinks: followLinks) !=
        FileSystemEntityType.notFound;

    verbose(
      () =>
          'exists(${truepath(path)}) found: $exists followLinks: $followLinks',
    );

    return exists;
  }

  /// checks if the given [path] exists.
  ///
  /// Throws [ArgumentError] if [path] is an empty string.
  bool existsSync(String path, {required bool followLinks}) {
    if (path.isEmpty) {
      throw ArgumentError('path must not be empty.');
    }

    final exists = FileSystemEntity.typeSync(path, followLinks: followLinks) !=
        FileSystemEntityType.notFound;

    verbose(
      () =>
          'exists(${truepath(path)}) found: $exists followLinks: $followLinks',
    );

    return exists;
  }

  DateTime lastModified(String path) => File(path).lastModifiedSync();

  void setLastModifed(String path, DateTime lastModified) {
    File(path).setLastModifiedSync(lastModified);
  }

  /// Returns true if the passed [pathToDirectory] is an
  /// empty directory.
  /// For large directories this operation can be expensive.
  bool isEmpty(String pathToDirectory) {
    final empty =
        Directory(pathToDirectory).listSync(followLinks: false).isEmpty;
    verbose(() => 'isEmpty(${truepath(pathToDirectory)}) : $empty');

    return empty;
  }
}
