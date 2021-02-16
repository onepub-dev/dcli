import 'dart:io';

import 'package:dcli/src/util/truepath.dart';

import '../settings.dart';

import 'dcli_function.dart';
import 'is.dart';

///
/// Pushes the given [path] onto the stack
/// and changes the current directory to [path]
///
/// ```dart
/// push('/tmp');
/// ```
///
/// If [path] is not a valid directory a
/// [PushException] is thrown.
///
/// Note: change the directory changes the directory
/// for all isolates.
///
/// See cd
///     [pop]
///     [pwd]
@Deprecated('Use join')
void push(String path) => _Push().push(path);

@Deprecated('Use join')
class _Push extends DCliFunction {
  /// Push the pwd onto the stack and change the
  /// current directory to [path].
  void push(String path) {
    Settings().verbose('push: path: $path new -> ${truepath(path)}');

    if (!exists(path)) {
      throw PushException('The path ${truepath(path)} does not exist.');
    }

    if (!isDirectory(path)) {
      throw PushException('The path ${truepath(path)} is not a directory.');
    }

    InternalSettings().push(Directory.current);

    try {
      Directory.current = path;
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw PushException(
          'An error occured pushing to ${truepath(path)}. Error $e');
    }
  }
}

// ignore:deprecated_member_use_from_same_package
/// Thrown when the [push] function encouters an error.
class PushException extends DCliFunctionException {
  // ignore:deprecated_member_use_from_same_package
  /// Thrown when the [push] function encouters an error.
  PushException(String reason) : super(reason);
}
