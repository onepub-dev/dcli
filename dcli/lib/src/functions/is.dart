/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:ffi';
import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:ffi/ffi.dart';
import 'package:posix/posix.dart' as posix;

import '../../dcli.dart';

/// checks if the passed [path] (a file or directory) is
/// writable by the user that owns this process
/// @Throwing(posix.StatException)
/// @Throwing(UnsupportedError)
bool isWritable(String path) {
  core.verbose(() => 'isWritable: ${truepath(path)}');
  return _checkPermission(path, _writeBitMask);
}

/// checks if the passed [path] (a file or directory) is
/// readable by the user that owns this process
/// @Throwing(posix.StatException)
/// @Throwing(UnsupportedError)
bool isReadable(String path) {
  core.verbose(() => 'isReadable: ${truepath(path)}');
  return _checkPermission(path, _readBitMask);
}

/// checks if the passed [path] (a file or directory) is
/// executable by the user that owns this process
/// @Throwing(posix.StatException)
/// @Throwing(UnsupportedError)
bool isExecutable(String path) {
  core.verbose(() => 'isExecutable: ${truepath(path)}');
  return Settings().isWindows || _checkPermission(path, _executeBitMask);
}

const _readBitMask = 0x4;
const _writeBitMask = 0x2;
const _executeBitMask = 0x1;

// macOS faccessat uses the effective identity with AT_EACCESS. Linux glibc
// before faccessat2 can silently use the real identity for that flag, so the
// Linux branch below calls euidaccess instead.
const _macAtFdcwd = -2;
const _macAtEaccess = 0x10;

final int Function(Pointer<Utf8>, int) _euidaccess = DynamicLibrary.process()
    .lookupFunction<
      Int32 Function(Pointer<Utf8>, Int32),
      int Function(Pointer<Utf8>, int)
    >('euidaccess');

/// Checks if the user permission to act on the [path] (a file or directory)
/// for the given permission bit mask. (read, write or execute)
/// Throws [UnsupportedError].
/// @Throwing(posix.StatException)
/// @Throwing(UnsupportedError)
bool _checkPermission(String path, int permissionBitMask) {
  core.verbose(
    () =>
        '_checkPermission: ${truepath(path)} '
        'permissionBitMask: $permissionBitMask',
  );

  if (Settings().isWindows) {
    throw UnsupportedError(
      'permission checks are not currently supported on windows',
    );
  }

  // Keep the previous missing-path exception. Dart's stat works on Linux
  // ARM64, where the posix package's __xstat version is not supported.
  if (FileStat.statSync(path).type == FileSystemEntityType.notFound) {
    throw posix.StatException('No such file or directory $path', 2);
  }

  if (Platform.isMacOS) {
    return posix.faccessat(
          _macAtFdcwd,
          path,
          permissionBitMask,
          _macAtEaccess,
        ) ==
        0;
  }

  final nativePath = path.toNativeUtf8();
  try {
    return _euidaccess(nativePath, permissionBitMask) == 0;
  } finally {
    malloc.free(nativePath);
  }
}

/// Returns true if the owner of this process
/// is a member of [group].
/// Throws [UnsupportedError].
/// @Throwing(UnsupportedError)
bool isMemberOfGroup(String group) {
  core.verbose(() => 'isMemberOfGroup: $group');

  if (Settings().isWindows) {
    throw UnsupportedError(
      'isMemberOfGroup is not Not currently supported on windows',
    );
  }
  try {
    final gid = posix.getgrnam(group).gid;
    return gid == posix.getegid() || posix.getgroups().contains(gid);
  } on posix.PosixException {
    return false;
  }
}
