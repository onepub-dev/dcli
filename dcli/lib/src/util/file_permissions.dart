/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

/// See http://dartbug.com/22036
library has_permission;

import 'dart:io';

// ignore: unused_field
enum FilePermission { read, write, execute, setUid, setGid, sticky }

// ignore: unused_field
enum FilePermissionRole { world, group, user }

/// Checks if the given file or directory at [path]
/// has the give permission for the given [role].
///
/// [role] defaults to world.
///
/// If the path doesn't exist then false is returned.
bool hasPermission(
  String path,
  FilePermission permission, {
  FilePermissionRole role = FilePermissionRole.world,
}) {
  final stat = FileStat.statSync(path);

  // if (stat.type == FileSystemEntityType.notFound)

  return _hasPermission(stat, permission);
}

bool _hasPermission(
  FileStat stat,
  FilePermission permission, {
  FilePermissionRole role = FilePermissionRole.world,
}) {
  final bitIndex = _getPermissionBitIndex(permission, role);
  return (stat.mode & (1 << bitIndex)) != 0;
}

int _getPermissionBitIndex(
  FilePermission permission,
  FilePermissionRole role,
) {
  switch (permission) {
    case FilePermission.setUid:
      return 11;
    case FilePermission.setGid:
      return 10;
    case FilePermission.sticky:
      return 9;
    case FilePermission.read:
    case FilePermission.write:
    case FilePermission.execute:
      return (role.index * 3) + permission.index;
  }
}
