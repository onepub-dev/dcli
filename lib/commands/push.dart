import 'dart:io';

import 'package:path/path.dart' as p;

import '../util/log.dart';

import 'command.dart';
import 'is.dart';
import 'settings.dart';

///
/// Pushes the given [path] onto the stack
/// and changes the current directory to [path]
///
/// ```dart
/// push("/tmp");
/// ```
///
/// If [path] is not a valid directory a
/// [PushException] is thrown.
///
/// Note: change the directory changes the directory
/// for all isolates.
///
/// See [cd]
///     [pop]
///     [pwd]

void push(String path) => Push().push(path);

class Push extends Command {
  /// Push the pwd onto the stack and change the
  /// current directory to [path].
  void push(String path) {
    if (Settings().debug_on) {
      Log.d("push: path: $path new -> ${p.absolute(path)}");
    }

    if (!exists(path)) {
      throw PushException("The path ${absolute(path)} does not exist.");
    }

    if (!isDirectory(path)) {
      throw PushException("The path ${absolute(path)} is not a directory.");
    }

    InternalSettings().push(Directory.current);

    try {
      Directory.current = path;
    } catch (e) {
      throw PushException(
          "An error occured pushing to ${absolute(path)}. Error $e");
    }
  }
}

class PushException extends CommandException {
  PushException(String reason) : super(reason);
}
