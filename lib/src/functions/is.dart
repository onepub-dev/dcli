import 'dart:io';

import 'package:meta/meta.dart';

import '../../dcli.dart';
import '../util/dcli_exception.dart';
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
    throw DCliException.from(e, StackTraceImpl());
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
    throw DCliException.from(e, StackTraceImpl());
  }
}

/// checks if the passed [path] (a file or directory) is
/// writable by the user that owns this process
bool isWritable(String path) => _Is().isWritable(path);

/// checks if the passed [path] (a file or directory) is
/// readable by the user that owns this process
bool isReadable(String path) => _Is().isReadable(path);

/// checks if the passed [path] (a file or directory) is
/// executable by the user that owns this process
bool isExecutable(String path) => _Is().isExecutable(path);

class _Is extends DCliFunction {
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
  ///
  /// Throws [ArgumentError] if [path] is null or an empty string.
  bool exists(String path, {@required bool followLinks}) {
    if (path == null || path.isEmpty) {
      throw ArgumentError('path must not be null or empty');
    }
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

  /// checks if the passed [path] (a file or directory) is
  /// writable by the user that owns this process
  bool isWritable(String path) {
    return _checkPermission(path, WRITE_BIT_MASK);
  }

  /// checks if the passed [path] (a file or directory) is
  /// readable by the user that owns this process
  bool isReadable(String path) {
    return _checkPermission(path, READ_BIT_MASK);
  }

  /// checks if the passed [path] (a file or directory) is
  /// executable by the user that owns this process
  bool isExecutable(String path) {
    return Settings().isWindows
        ? true
        : _checkPermission(path, EXECUTE_BIT_MASK);
  }

  static const READ_BIT_MASK = 0x4;
  static const WRITE_BIT_MASK = 0x2;
  static const EXECUTE_BIT_MASK = 0x1;

  /// Checks if the user permission to act on the [path] (a file or directory)
  /// for the given permission bit mask. (read, write or execute)
  bool _checkPermission(String path, int permissionBitMask) {
    if (Settings().isWindows) {
      throw UnsupportedError(
          'isMemberOfGroup is not Not currently supported on windows');
    }

    var user = env['USER'];

    //e.g 755 tomcat bsutton
    var stat = 'stat -L -c "%a %G %U" "$path"'.firstLine;

    var parts = stat.split(' ');

    var permissions = int.parse(parts[0], radix: 8);
    var group = parts[1];
    var owner = parts[2];

    // var group = mode.substring(8,16);
    // var owner = mode.substring(16,24);

    var access = false;
    //  if (( ($PERM & 0002) != 0 )); then
    if ((permissions & permissionBitMask) != 0) {
      // Everyone has write access
      access = true;
    } else if ((permissions & (permissionBitMask << 3)) != 0) {
      // Some groups have write access
      if (isMemberOfGroup(group)) {
        access = true;
      }
    } else if ((permissions & (permissionBitMask << 6)) != 0) {
      if (user == owner) {
        access = true;
      }
    }
    return access;
  }

  /// Returns true if the owner of this process
  /// is a member of [group].
  bool isMemberOfGroup(String group) {
    if (Settings().isWindows) {
      throw UnsupportedError(
          'isMemberOfGroup is not Not currently supported on windows');
    }
    // get the list of groups this user belongs to.
    var groups = 'groups'.firstLine.split(' ');

    // is the user a member of the file's group.
    return (groups.contains(group));
  }
}
