/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'package:dcli_core/dcli_core.dart' as core;
import 'package:posix/posix.dart' as _posix;

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
void chown(String path, {String? user, String? group, bool recursive = true}) =>
    _ChOwn()._chown(path, user: user, group: group, recursive: recursive);

/// Implementatio for [chown] function.
class _ChOwn extends core.DCliFunction {
// this.user, this.group, this.other, this.path

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

    final passwd = _posix.getpwnam(user);
    final pgroup = _posix.getgrnam(group);
    if (isDirectory(path) && recursive) {
      find('*', includeHidden: true, workingDirectory: path)
          .forEach((file) => _posix.chown(path, passwd.uid, pgroup.gid));
    } else {
      _posix.chown(path, passwd.uid, pgroup.gid);
    }
  }
}

/// Thrown if the [chown] function encounters an error.
class ChOwnException extends core.DCliFunctionException {
  /// Thrown if the [chown] function encounters an error.
  ChOwnException(String reason, [core.StackTraceImpl? stacktrace])
      : super(reason, stacktrace);

  // @override
  // DCliException copyWith(core.StackTraceImpl stackTrace) =>
  //     ChOwnException(message, stackTrace);
}
