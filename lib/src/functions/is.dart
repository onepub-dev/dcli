import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_core/dcli_core.dart';

import '../../dcli.dart';

///
/// Returns true if the given [path] points to a file.
/// If [path] is a link the link will be followed and
/// we report on the resolved path.
///
/// ```dart
/// isFile("~/fred.jpg");
/// ```
bool isFile(String path) => waitForEx(core.isFile(path));

/// Returns true if the given [path] is a directory.
///
/// If [path] is a link the link will be followed and
/// we report on the resolved path.
/// ```dart
/// isDirectory("/tmp");
///
/// ```
bool isDirectory(String path) => waitForEx(core.isDirectory(path));

/// Returns true if the given [path] is a symlink
///
/// // ```dart
/// isLink("~/fred.jpg");
/// ```
bool isLink(String path) => waitForEx(core.isLink(path));

/// Returns true if the given path exists.
/// It may be a file, directory or link.
///
/// If [followLinks] is true (the default) then [exists]
/// follows any links and returns true/false based on
/// whether the resolved path exists.
///
/// If [followLinks] is false then [exists] will return
/// true if [path] exist.
///
/// ```dart
/// if (exists("/fred.txt"))
/// ```
///
/// Throws [ArgumentError] if [path] is null or an empty string.
///
/// See:
///  * [isLink]
///  * [isDirectory]
///  * [isFile]
bool exists(String path, {bool followLinks = true}) =>
    waitForEx(core.exists(path, followLinks: followLinks));

/// Returns the datetime the path was last modified
///
/// [path[ can be either a file or a directory.
///
/// Throws a [DCliException] with a nested
/// [FileSystemException] if the file does not
/// exist or the operation fails.
DateTime lastModified(String path) => waitForEx(core.lastModified(path));

/// Sets the last modified datetime on the given the path.
///
/// [path] can be either a file or a directory.
///
/// Throws a [DCliException] with a nested
/// [FileSystemException] if the file does not
/// exist or the operation fails.

void setLastModifed(String path, DateTime lastModified) =>
    waitForEx(core.setLastModifed(path, lastModified));

/// Returns true if the passed [pathToDirectory] is an
/// empty directory.
/// For large directories this operation can be expensive.
bool isEmpty(String pathToDirectory) =>
    waitForEx(core.isEmpty(pathToDirectory));

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
  /// checks if the passed [path] (a file or directory) is
  /// writable by the user that owns this process
  bool isWritable(String path) {
    verbose(() => 'isWritable: ${truepath(path)}');
    return _checkPermission(path, writeBitMask);
  }

  /// checks if the passed [path] (a file or directory) is
  /// readable by the user that owns this process
  bool isReadable(String path) {
    verbose(() => 'isReadable: ${truepath(path)}');
    return _checkPermission(path, readBitMask);
  }

  /// checks if the passed [path] (a file or directory) is
  /// executable by the user that owns this process
  bool isExecutable(String path) {
    verbose(() => 'isExecutable: ${truepath(path)}');
    return Platform.isWindows || _checkPermission(path, executeBitMask);
  }

  static const readBitMask = 0x4;
  static const writeBitMask = 0x2;
  static const executeBitMask = 0x1;

  /// Checks if the user permission to act on the [path] (a file or directory)
  /// for the given permission bit mask. (read, write or execute)
  bool _checkPermission(String path, int permissionBitMask) {
    verbose(
      () => '_checkPermission: ${truepath(path)} '
          'permissionBitMask: $permissionBitMask',
    );

    if (Platform.isWindows) {
      throw UnsupportedError(
        'isMemberOfGroup is not Not currently supported on windows',
      );
    }

    final user = Shell.current.loggedInUser;

    int permissions;
    String group;
    String owner;
    bool otherWritable;
    bool groupWritable;
    bool ownerWritable;

    // try {
    //   final _stat = posix.stat(path);
    //   group = posix.getgrgid(_stat.gid).name;
    //   owner = posix.getUserNameByUID(_stat.uid);
    //   final mode = _stat.mode;
    //   otherWritable = mode.isOtherWritable;
    //   groupWritable = mode.isGroupWritable;
    //   ownerWritable = mode.isOwnerWritable;
    // } on posix.PosixException catch (_) {
    //e.g 755 tomcat bsutton
    final stat = 'stat -L -c "%a %G %U" "$path"'.firstLine!;
    final parts = stat.split(' ');
    permissions = int.parse(parts[0], radix: 8);
    group = parts[1];
    owner = parts[2];
    //  if (( ($PERM & 0002) != 0 )); then
    otherWritable = (permissions & permissionBitMask) != 0;
    groupWritable = (permissions & (permissionBitMask << 3)) != 0;
    ownerWritable = (permissions & (permissionBitMask << 6)) != 0;
    // }

    var access = false;
    if (otherWritable) {
      // Everyone has write access
      access = true;
    } else if (groupWritable) {
      // Some groups have write access
      if (isMemberOfGroup(group)) {
        access = true;
      }
    } else if (ownerWritable) {
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

    if (Platform.isWindows) {
      throw UnsupportedError(
        'isMemberOfGroup is not Not currently supported on windows',
      );
    }
    // get the list of groups this user belongs to.
    final groups = 'groups'.firstLine!.split(' ');

    // is the user a member of the file's group.
    return groups.contains(group);
  }
}
