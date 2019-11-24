import 'dart:io';
import 'package:dshell/functions/function.dart';

import '../util/log.dart';

import 'settings.dart';

/// Creates a directory as described by [path]
/// Path may be a single path segment (e.g. bin)
/// or a full or partial tree (e.g. /usr/bin)
///
/// ```dart
/// createDir("/tmp/fred/tools", createParent=true);
/// ```
///
/// If [createParent] is true then any parent
/// paths that don't exist will be created.
///
/// If [createParent] is false then any parent paths
/// don't exist then a [MakeDireExcepption] will be thrown
///
void createDir(String path, {bool createParent = false}) =>
    CreateDir().createDir(path, createParent: createParent);

class CreateDir extends DShellFunction {
  void createDir(String path, {bool createParent}) {
    if (Settings().debug_on) {
      Log.d("createDir:  ${absolute(path)} createPath: $createParent");
    }

    try {
      Directory(path).createSync(recursive: createParent);
    } catch (e) {
      throw MakeDirException(
          "Unable to create the directory ${absolute(path)}. Error: ${e}");
    }
  }
}

class MakeDirException extends FunctionException {
  MakeDirException(String reason) : super(reason);
}
