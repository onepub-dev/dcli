import 'dart:io';

import '../../dcli.dart';
import '../settings.dart';
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

/// Returns true if the passed [pathToDirectory] is an
/// empty directory.
/// For large directories this operation can be expensive.
bool isEmpty(String pathToDirectory) => _Is().isEmpty(pathToDirectory);

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
    final fromType = FileSystemEntity.typeSync(path);
    return fromType == FileSystemEntityType.file;
  }

  /// true if the given path is a directory.
  bool isDirectory(String path) {
    final fromType = FileSystemEntity.typeSync(path);
    return fromType == FileSystemEntityType.directory;
  }

  bool isLink(String path) {
    final fromType = FileSystemEntity.typeSync(path);
    return fromType == FileSystemEntityType.link;
  }

  /// checks if the given [path] exists.
  ///
  /// Throws [ArgumentError] if [path] is an empty string.
  bool exists(String path, {required bool followLinks}) {
    if (path.isEmpty) {
      throw ArgumentError('path must not be empty.');
    }

    final _exists = FileSystemEntity.typeSync(path, followLinks: followLinks) !=
        FileSystemEntityType.notFound;

    verbose(() => 'exists: $_exists $path followLinks: $followLinks');

    return _exists;
  }

  DateTime lastModified(String path) => File(path).lastModifiedSync();

  void setLastModifed(String path, DateTime lastModified) {
    File(path).setLastModifiedSync(lastModified);
  }

  /// Returns true if the passed [pathToDirectory] is an
  /// empty directory.
  /// For large directories this operation can be expensive.
  bool isEmpty(String pathToDirectory) {
    verbose(() => 'isEmpty: $pathToDirectory');

    return Directory(pathToDirectory).listSync(followLinks: false).isEmpty;
  }

  /// checks if the passed [path] (a file or directory) is
  /// writable by the user that owns this process
  bool isWritable(String path) {
    verbose(() => 'isWritable: $path');
    return _checkPermission(path, writeBitMask);
  }

  /// checks if the passed [path] (a file or directory) is
  /// readable by the user that owns this process
  bool isReadable(String path) {
    verbose(() => 'isReadable: $path');
    return _checkPermission(path, readBitMask);
  }

  /// checks if the passed [path] (a file or directory) is
  /// executable by the user that owns this process
  bool isExecutable(String path) {
    verbose(() => 'isExecutable: $path');
    return Settings().isWindows || _checkPermission(path, executeBitMask);
  }

  static const readBitMask = 0x4;
  static const writeBitMask = 0x2;
  static const executeBitMask = 0x1;

  /// Checks if the user permission to act on the [path] (a file or directory)
  /// for the given permission bit mask. (read, write or execute)
  bool _checkPermission(String path, int permissionBitMask) {
    verbose(
        () => '_checkPermission: $path permissionBitMask: $permissionBitMask');

    if (Settings().isWindows) {
      throw UnsupportedError(
          'isMemberOfGroup is not Not currently supported on windows');
    }

    final user = Shell.current.loggedInUser;

    //e.g 755 tomcat bsutton
    final stat = 'stat -L -c "%a %G %U" "$path"'.firstLine!;

    final parts = stat.split(' ');

    final permissions = int.parse(parts[0], radix: 8);
    final group = parts[1];
    final owner = parts[2];

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
    verbose(() => 'isMemberOfGroup: $group');

    if (Settings().isWindows) {
      throw UnsupportedError(
          'isMemberOfGroup is not Not currently supported on windows');
    }
    // get the list of groups this user belongs to.
    final groups = 'groups'.firstLine!.split(' ');

    // is the user a member of the file's group.
    return groups.contains(group);
  }
}
