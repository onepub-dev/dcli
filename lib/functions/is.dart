import 'dart:io';

import 'package:dshell/functions/function.dart';
import 'package:dshell/util/dshell_exception.dart';
import 'package:dshell/util/stack_trace_impl.dart';

///
/// Returns true if the given path points to a file.
///
/// ```dart
/// isFile("~/fred.jpg");
/// ```
bool isFile(String path) => Is().isFile(path);

/// Returns try if the given path is a directory.
/// ```dart
/// isDirectory("/tmp");
///
/// ```
bool isDirectory(String path) => Is().isDirectory(path);

/// returns true if the given path exists.
/// It may be a file, directory or link.
///
/// If [followLinks] is true (the default) then exists
/// will return true if the resolved path exists.
///
/// If [followLinks] is false then [exists] will return
/// true if path exist, whether its a link or not.
///
/// ```dart
/// if (exists("/fred.txt"))
/// ```
bool exists(String path, {bool followLinks = true}) =>
    Is().exists(path, followLinks);

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

class Is extends DShellFunction {
  bool isFile(String path) {
    FileSystemEntityType fromType = FileSystemEntity.typeSync(path);
    return (fromType == FileSystemEntityType.file);
  }

  /// true if the given path is a directory.
  bool isDirectory(String path) {
    FileSystemEntityType fromType = FileSystemEntity.typeSync(path);
    return (fromType == FileSystemEntityType.directory);
  }

  /// checks if the given [path] exists.
  bool exists(String path, bool followLinks) {
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
