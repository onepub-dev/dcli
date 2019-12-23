/// See http://dartbug.com/22036
library has_permission;

import 'dart:io';

enum FilePermission { READ, WRITE, EXECUTE, SET_UID, SET_GID, STICKY }
enum FilePermissionRole { WORLD, GROUP, USER }

/// Checks if the given file or directory at [path]
/// has the give permission for the given [role].
///
/// [role] defaults to world.
///
/// If the path doesn't exist then false is returned.
bool hasPermission(String path, FilePermission permission,
    {FilePermissionRole role = FilePermissionRole.WORLD}) {
  var stat = FileStat.statSync(path);

  // if (stat.type == FileSystemEntityType.notFound)

  return _hasPermission(stat, permission);
}

bool _hasPermission(FileStat stat, FilePermission permission,
    {FilePermissionRole role = FilePermissionRole.WORLD}) {
  var bitIndex = _getPermissionBitIndex(permission, role);
  return (stat.mode & (1 << bitIndex)) != 0;
}

int _getPermissionBitIndex(FilePermission permission, FilePermissionRole role) {
  switch (permission) {
    case FilePermission.SET_UID:
      return 11;
    case FilePermission.SET_GID:
      return 10;
    case FilePermission.STICKY:
      return 9;
    default:
      return (role.index * 3) + permission.index;
  }
}
