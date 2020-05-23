import 'dart:io';

import 'package:meta/meta.dart';

import '../util/dshell_exception.dart';
import '../util/stack_trace_impl.dart';
import 'function.dart';

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
/// See [isLink]
///     [isDirectory]
///     [isFile]
bool exists(String path, {bool followLinks = true}) =>
    _Is().exists(path, followLinks: followLinks);

/// Returns the datetime the path was last modified
///
/// [path[ can be either a file or a directory.
///
/// Throws a [DShellException] with a nested
/// [FileSystemException] if the file does not
/// exist or the operation fails.
DateTime lastModified(String path) {
  try {
    return File(path).lastModifiedSync();
  } on FileSystemException catch (e) {
    throw DShellException.from(e, StackTraceImpl());
  }
}

/// Sets the last modified datetime on the given the path.
///
/// [path] can be either a file or a directory.
///
/// Throws a [DShellException] with a nested
/// [FileSystemException] if the file does not
/// exist or the operation fails.

void setLastModifed(String path, DateTime lastModified) {
  try {
    File(path).setLastModifiedSync(lastModified);
  } on FileSystemException catch (e) {
    throw DShellException.from(e, StackTraceImpl());
  }
}

class _Is extends DShellFunction {
  bool isFile(String path) {
    var fromType = FileSystemEntity.typeSync(path);
    return (fromType == FileSystemEntityType.file);
  }

  /// true if the given path is a directory.
  bool isDirectory(String path) {
    var fromType = FileSystemEntity.typeSync(path);
    return (fromType == FileSystemEntityType.directory);
  }

  bool isLink(String path) {
    var fromType = FileSystemEntity.typeSync(path);
    return (fromType == FileSystemEntityType.link);
  }

  /// checks if the given [path] exists.
  bool exists(String path, {@required bool followLinks}) {
    //return FileSystemEntity.existsSync(path);
    return FileSystemEntity.typeSync(path, followLinks: followLinks) !=
        FileSystemEntityType.notFound;
  }

  DateTime lastModified(String path) {
    return File(path).lastModifiedSync();
  }

  void setLastModifed(String path, DateTime lastModified) {
    File(path).setLastModifiedSync(lastModified);
  }
}
