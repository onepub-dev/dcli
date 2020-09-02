import 'dart:io';
import '../../dcli.dart';
import '../settings.dart';
import 'function.dart';

/// Creates a directory as described by [path].
/// Path may be a single path segment (e.g. bin)
/// or a full or partial tree (e.g. /usr/bin)
///
/// ```dart
/// createDir("/tmp/fred/tools", recursive=true);
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

String createDir(String path, {bool recursive = false}) => _CreateDir().createDir(path, recursive: recursive);

class _CreateDir extends DCliFunction {
  String createDir(String path, {bool recursive}) {
    Settings().verbose('createDir:  ${absolute(path)} recursive: $recursive');

    try {
      if (exists(path)) {
        throw CreateDirException('The path ${absolute(path)} already exists');
      }

      Directory(path).createSync(recursive: recursive);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw CreateDirException('Unable to create the directory ${absolute(path)}. Error: $e');
    }
    return path;
  }
}

/// Thrown when the function [createDir] encounters an error
class CreateDirException extends FunctionException {
  /// Thrown when the function [createDir] encounters an error
  CreateDirException(String reason) : super(reason);
}
