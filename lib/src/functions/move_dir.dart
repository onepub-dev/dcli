import 'dart:io';

import '../../dcli.dart';
import '../settings.dart';
import 'function.dart';

import 'is.dart';

/// Moves or renames the [from] directory to the
/// to the [to] path.
///
/// The [to] path must NOT exist.
///
/// The [from] path must be a directory.
///
/// [moveDir] first tries to rename the directory, if that
/// fails due to the [to] path being on a different device
/// we fall back to a copy/delete operation.
///
/// ```dart
/// moveDir("/tmp/", "/tmp/new_dir");
/// ```
///
/// Throws a [MoveDirException] if:
///   the [from] path doesn't exist
///   the [from] path isn't a directory
///   the [to] path already exists.
///
void moveDir(String from, String to) => _MoveDir().moveDir(
      from,
      to,
    );

class _MoveDir extends DCliFunction {
  void moveDir(String from, String to) {
    if (!exists(from)) {
      throw MoveDirException(
          'The [from] path ${truepath(from)} does not exists.');
    }
    if (!isDirectory(from)) {
      throw MoveDirException(
          'The [from] path ${truepath(from)} must be a directory.');
    }
    if (exists(to)) {
      throw MoveDirException('The [to] path ${truepath(to)} must NOT exist.');
    }

    Settings().verbose('moveDir called ${truepath(from)} -> ${truepath(to)}');

    try {
      Directory(from).renameSync(to);
    } on FileSystemException catch (e) {
      if (e.osError != null && e.osError!.errorCode == 18) {
        /// Invalid cross-device link
        /// We can't move files across a partition so
        /// do a copy/delete.
        Settings().verbose(
            'moveDir to is on a separate device so falling back to copy/delete: ${truepath(from)} -> ${truepath(to)}');

        copyTree(from, to, includeHidden: true);
        delete(from);
      } else {
        throw MoveDirException(
            'The Move of ${truepath(from)} to ${truepath(to)} failed.'
            ' Error $e');
      }
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw MoveDirException(
          'The Move of ${truepath(from)} to ${truepath(to)} failed. Error $e');
    }
  }
}

/// Thrown when the [moveDir] function encouters an error.
class MoveDirException extends FunctionException {
  /// Thrown when the [moveDir] function encouters an error.
  MoveDirException(String reason) : super(reason);
}
