/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:posix/posix.dart' as posix;

import '../../dcli.dart';

/// Sets the owner of a file on posix systems.
///
/// Changes the user or group ownership of [path].
///
/// On Windows this command has no effect.
///
/// [path] is the path to the file or directory that we are changing the
/// ownership of. If [path] does not exists then a [ChOwnException] is thrown.
/// [path] may be absolute (preferred) or relative.
///
/// [user] is the posix user that will own the file/directory. If no [user] is specified
/// then the loggedin user is used.
///
/// [group] is the posix group that will own the file/directory. If no [group] is specified
/// then [user] is used as the group name.
///
/// If [recursive] is true (the default) then the change is applied to
///  all subdirectories.
/// If you pass [recursive] and [path] is a file then [recursive]
/// will be ignored.
///
/// @Throwing(ArgumentError)
/// @Throwing(ChOwnException)
/// @Throwing(posix.PosixException)
void chown(String path, {String? user, String? group, bool recursive = true}) =>
    _ChOwn()._chown(path, user: user, group: group, recursive: recursive);

/// Implementatio for [chown] function.
class _ChOwn extends core.DCliFunction {
// this.user, this.group, this.other, this.path

  /// Throws [ChOwnException].
  /// @Throwing(ArgumentError)
  /// @Throwing(ChOwnException)
  /// @Throwing(posix.PosixException)
  void _chown(
    String path, {
    String? user,
    String? group,
    bool recursive = true,
  }) {
    if (Settings().isWindows) {
      return;
    }

    user ??= Shell.current.loggedInUser ?? '';

    group ??= user;
    if (!exists(path)) {
      throw ChOwnException(
        'The file/directory at ${truepath(path)} does not exists',
      );
    }

    final passwd = posix.getpwnam(user);
    final pgroup = posix.getgrnam(group);
    posix.chown(path, passwd.uid, pgroup.gid);
    if (isDirectory(path) && recursive) {
      find('*',
              includeHidden: true,
              types: [Find.directory, Find.file, Find.link],
              workingDirectory: path)
          .forEach((file) => posix.chown(path, passwd.uid, pgroup.gid));
    }
  }
}

/// Thrown if the [chown] function encounters an error.
class ChOwnException extends core.DCliFunctionException {
  /// Thrown if the [chown] function encounters an error.
  ChOwnException(super.message, [super.stacktrace]);
}
