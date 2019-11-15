import 'dart:io';
import 'package:dshell/commands/command.dart';

import '../util/log.dart';

import 'settings.dart';

/// Creates a directory as described by [path]
/// Path may be a single path segment (e.g. bin)
/// or a full or partial tree (e.g. /usr/bin)
///
/// If [createParent] is true then any parent
/// paths that don't exist will be created.
///
/// If [createParent] is false then any parent paths
/// don't exist then a [MakeDireExcepption] will be thrown
///
void makeDir(String path, {bool createParent = false}) =>
    MakeDir().mkdir(path, createParent: createParent);

class MakeDir extends Command {
  void mkdir(String path, {bool createParent}) {
    if (Settings().debug_on) {
      Log.d("mkdir:  ${absolute(path)} createPath: $createParent");
    }

    try {
      Directory(path).createSync(recursive: createParent);
    } catch (e) {
      throw MakeDirException(
          "Unable to create the directory ${absolute(path)}. Error: ${e}");
    }
  }
}

class MakeDirException extends CommandException {
  MakeDirException(String reason) : super(reason);
}
