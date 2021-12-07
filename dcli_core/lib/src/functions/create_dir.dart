import 'dart:io';

import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../../dcli_core.dart';
import '../util/logging.dart';

/// Creates a directory as described by [path].
/// Path may be a single path segment (e.g. bin)
/// or a full or partial tree (e.g. /usr/bin)
///
/// ```dart
/// createDir("/tmp/fred/tools", recursive: true);
/// ```
///
/// If [recursive] is true then any parent
/// paths that don't exist will be created.
///
/// If [recursive] is false then any parent paths
/// don't exist then a [CreateDirException] will be thrown.
///
/// If the [path] already exists an exception is thrown.
///
/// As a convenience [createDir] returns the same path
/// that it was passed.
///
/// ```dart
///  var path = createDir('/tmp/new_home'));
/// ```
///

Future<String> createDir(String path, {bool recursive = false}) async =>
    _CreateDir().createDir(path, recursive: recursive);

/// Creates a temp directory and then calls [action].
/// Once action completes the temporary directory will be deleted.
///
/// The actions return value [R] is returned from the [withTempDir]
/// function.
///
/// If you pass [keep] = true then the temp directory won't be deleted.
/// This can be useful when testing and you need to examine the temp directory.
Future<R> withTempDir<R>(R Function(String tempDir) action,
    {bool keep = false}) async {
  final dir = await createTempDir();

  R result;
  try {
    result = action(dir);
  } finally {
    if (!keep) {
      await deleteDir(dir);
    }
  }
  return result;
}

/// Creates a temporary directory under the system temp folder.
/// The temporary directory name is formed from a uuid.
/// It is your responsiblity to delete the directory once you have
/// finsihed with it.
Future<String> createTempDir() async => _CreateDir().createDir(
      join(Directory.systemTemp.path, const Uuid().v4()),
      recursive: false,
    );

class _CreateDir extends DCliFunction {
  Future<String> createDir(String path, {required bool recursive}) async {
    verbose(() => 'createDir:  ${truepath(path)} recursive: $recursive');

    try {
      if (exists(path)) {
        throw CreateDirException('The path ${truepath(path)} already exists');
      }

      await Directory(path).create(recursive: recursive);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw CreateDirException(
        'Unable to create the directory ${truepath(path)}. Error: $e',
      );
    }
    return path;
  }
}

/// Thrown when the function [createDir] encounters an error
class CreateDirException extends DCliFunctionException {
  /// Thrown when the function [createDir] encounters an error
  CreateDirException(String reason) : super(reason);
}
