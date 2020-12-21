/// See http://dartbug.com/22036
library has_permission;

import 'dart:io';

// ignore: unused_field
enum _FilePermission { read, write, execute, setUid, setGid, sticky }
// ignore: unused_field
enum _FilePermissionRole { world, group, user }

/// Checks if the given file or directory at [path]
/// has the give permission for the given [role].
///
/// [role] defaults to world.
///
/// If the path doesn't exist then false is returned.
bool hasPermission(String path, _FilePermission permission,
    {_FilePermissionRole role = _FilePermissionRole.world}) {
  final stat = FileStat.statSync(path);

  // if (stat.type == FileSystemEntityType.notFound)

  return _hasPermission(stat, permission);
}

bool _hasPermission(FileStat stat, _FilePermission permission,
    {_FilePermissionRole role = _FilePermissionRole.world}) {
  final bitIndex = _getPermissionBitIndex(permission, role);
  return (stat.mode & (1 << bitIndex)) != 0;
}

int _getPermissionBitIndex(
    _FilePermission permission, _FilePermissionRole role) {
  switch (permission) {
    case _FilePermission.setUid:
      return 11;
    case _FilePermission.setGid:
      return 10;
    case _FilePermission.sticky:
      return 9;
    default:
      return (role.index * 3) + permission.index;
  }
}
