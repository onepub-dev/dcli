import 'package:path/path.dart';

import '../../dcli.dart';
import '../settings.dart';
import 'function.dart';

import 'is.dart';

/// Recursively moves the contents of the [from] directory to the
/// to the [to] path with an optional filter.
///
/// When filtering any files that don't match the filter will be
/// left in the [from] directory tree.
///
/// Any [from] directories that are emptied as a result of the move will
/// be removed. This includes the [from] directory itself.
///
/// [from] must be a directory
///
/// [to] must be a directory and its parent directory must exist.
///
/// If any moved files already exists in the [to] path then
/// an exeption is throw and a parital move may occured.
///
/// You can force moveTree to overwrite files in the [to]
/// directory by setting [overwrite] to true (defaults to false).
///
///
/// ```dart
/// moveTree("/tmp/", "/tmp/new_dir", overwrite: true);
/// ```
///
/// By default hidden files are ignored. To allow hidden files to
/// be passed set [includeHidden] to true.
///
/// You can select which files/directories are to be moved by passing a [filter].
/// If a [filter] isn't passed then all files/directories are copied as per
/// the [includeHidden] state.
///
/// ```dart
/// moveTree("/tmp/", "/tmp/new_dir", overwrite: true
///   , filter: (file) => extension(file) == 'dart');
/// ```
///
/// The [filter] method can also be used to report progress as it
/// is called just before we move a file or directory.
///
/// ```dart
/// moveTree("/tmp/", "/tmp/new_dir", overwrite: true
///   , filter: (entity) {
///   var include = extension(entity) == 'dart';
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
/// If an error occurs a [MoveTreeException] is thrown.
///
/// EXPERIMENTAL
void moveTree(String from, String to,
        {bool overwrite = false,
        bool includeHidden = false,
        bool Function(String file) filter = _allowAll}) =>
    _MoveTree().moveTree(
      from,
      to,
      overwrite: overwrite,
      includeHidden: includeHidden,
      filter: filter,
    );

bool _allowAll(String file) => true;

class _MoveTree extends DCliFunction {
  void moveTree(
    String from,
    String to, {
    bool overwrite = false,
    bool Function(String file) filter = _allowAll,
    bool includeHidden = false,
  }) {
    if (!isDirectory(from)) {
      throw MoveTreeException(
          'The [from] path ${truepath(from)} must be a directory.');
    }
    if (!exists(to)) {
      throw MoveTreeException(
          'The [to] path ${truepath(to)} must already exist.');
    }

    if (!isDirectory(to)) {
      throw MoveTreeException(
          'The [to] path ${truepath(to)} must be a directory.');
    }

    Settings().verbose('moveTree called ${truepath(from)} -> ${truepath(to)}');

    try {
      find(
        '*',
        workingDirectory: from,
        includeHidden: includeHidden,
      ).forEach((file) {
        if (filter(file)) {
          final target = join(to, relative(file, from: from));

          // we create directories as we go.
          // only directories that contain a file that is to be
          // moved will be created.
          if (isDirectory(dirname(file))) {
            if (!exists(dirname(target))) {
              createDir(dirname(target), recursive: true);
            }
          }

          if (!overwrite && exists(target)) {
            throw MoveTreeException(
                'The target file ${truepath(to)} already exists');
          }

          move(file, target, overwrite: overwrite);
          Settings().verbose(
              'moveTree copying: ${truepath(from)} -> ${truepath(target)}');
        }
      });
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw MoveTreeException(
          'An error occured copying directory ${truepath(from)} '
          'to ${truepath(to)}. Error: $e');
    }
  }
}

/// Thrown when the [moveTree] function encouters an error.
class MoveTreeException extends FunctionException {
  /// Thrown when the [moveTree] function encouters an error.
  MoveTreeException(String reason) : super(reason);
}
