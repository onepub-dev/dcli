import 'package:path/path.dart';

import '../../dshell.dart';
import '../settings.dart';
import 'function.dart';

import 'is.dart';

/// EXPERIMENTAL
///
/// There are still questions on what constitutes a move.
/// If we are only moving some files should we delete
/// any empty directories in the from tree?
/// Curently the [from] tree is left intact.
///
/// Moves the contents of the [from] directory to the
/// to the [to] path.
///
/// The [to] path must exist.
///
/// If any moved files already exists in the [to] path then
/// an exeption is throw and a parital move may occured.
///
/// You can force moveDir to overwrite files in the [to]
/// directory by setting [overwrite] to true (defaults to false).
///
///
/// ```dart
/// moveDir("/tmp/", "/tmp/new_dir", overwrite=true);
/// ```
///
/// By default hidden files are ignored. To allow hidden files to
/// be passed set [includeHidden] to true.
///
/// If [recursive] is true then the entire directory tree will be created.
/// Whilst the top level directory MUST exist any subdirecties will be
/// created as needed.
///
/// You can select which files are to be moved by passing a [filter].
/// If a [filter] isn't passed then all files/directories are copied as per
/// the [includeHidden] state.
///
/// ```dart
/// moveDir("/tmp/", "/tmp/new_dir", overwrite=true
///   , filter: (file) => extension(file) == 'dart');
/// ```
///
/// The [filter] method can also be used to report progress as it
/// is called just before we move a file.
///
/// ```dart
/// moveDir("/tmp/", "/tmp/new_dir", overwrite=true
///   , filter: (file) {
///   var include = extension(file) == 'dart';
///   if (include) {
///     print('moving: $file');
///   }
///   return include;
/// });
/// ```
///
///
/// The default for [overwrite] is false.
///
/// If an error occurs a [MoveDirException] is thrown.
///
/// EXPERIMENTAL
void moveDir(String from, String to,
        {bool overwrite = false,
        bool includeHidden = false,
        bool recursive = false,
        bool Function(String file) filter}) =>
    _MoveDir().moveDir(
      from,
      to,
      overwrite: overwrite,
      includeHidden: includeHidden,
      recursive: recursive,
      filter: filter,
    );

class _MoveDir extends DShellFunction {
  void moveDir(
    String from,
    String to, {
    bool overwrite = false,
    bool Function(String file) filter,
    bool includeHidden,
    bool recursive,
  }) {
    if (!isDirectory(from)) {
      throw MoveDirException(
          'The [from] path ${truepath(from)} must be a directory.');
    }
    if (!exists(to)) {
      throw MoveDirException(
          'The [to] path ${truepath(to)} must already exist.');
    }

    if (!isDirectory(to)) {
      throw MoveDirException(
          'The [to] path ${truepath(to)} must be a directory.');
    }

    Settings().verbose('moveDir called ${truepath(from)} -> ${truepath(to)}');

    try {
      find(
        '*',
        root: from,
        includeHidden: includeHidden,
        recursive: recursive,
      ).forEach((file) {
        var include = true;
        if (filter != null) include = filter(file);
        if (include) {
          var target = join(to, relative(file, from: from));

          // we create directories as we go.
          // only directories that contain a file that is to be
          // moved will be created.
          if (isDirectory(dirname(file))) {
            if (!exists(dirname(target))) {
              createDir(dirname(target), recursive: true);
            }
          }

          if (!overwrite && exists(target)) {
            throw MoveDirException(
                'The target file ${truepath(to)} already exists');
          }

          move(file, target, overwrite: overwrite);
          Settings().verbose(
              'moveDir copying: ${truepath(from)} -> ${truepath(target)}');
        }
      });
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw MoveDirException(
          'An error occured copying directory ${truepath(from)} to ${truepath(to)}. Error: $e');
    }
  }
}

/// Thrown when the [moveDir] function encouters an error.
class MoveDirException extends FunctionException {
  /// Thrown when the [moveDir] function encouters an error.
  MoveDirException(String reason) : super(reason);
}
