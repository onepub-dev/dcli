import 'dart:io';
import '../../dcli.dart';
import '../settings.dart';
import 'function.dart';

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

String createDir(String path, {bool recursive = false}) =>
    _CreateDir().createDir(path, recursive: recursive);

/// Creates a temporary directory under the system temp folder.
/// The temporary directory name is formed from a uuid.
/// It is your responsiblity to delete the directory once you have
/// finsihed with it.
String createTempDir() =>
    _CreateDir().createDir('${Directory.systemTemp}/${const Uuid().v4()}',
        recursive: false);

class _CreateDir extends DCliFunction {
  String createDir(String path, {required bool recursive}) {
    Settings().verbose('createDir:  ${truepath(path)} recursive: $recursive');

    try {
      if (exists(path)) {
        throw CreateDirException('The path ${truepath(path)} already exists');
      }

      Directory(path).createSync(recursive: recursive);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw CreateDirException(
          'Unable to create the directory ${truepath(path)}. Error: $e');
    }
    return path;
  }
}

/// Thrown when the function [createDir] encounters an error
class CreateDirException extends FunctionException {
  /// Thrown when the function [createDir] encounters an error
  CreateDirException(String reason) : super(reason);
}
