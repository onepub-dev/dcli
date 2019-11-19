import 'dart:io';
import 'package:dshell/commands/command.dart';

import '../util/log.dart';

import 'is.dart';
import 'settings.dart';

///
/// Deletes the directory at [path]
///
/// If [recursive] is true then the directory and all child files
/// and directories will be deleted.
///
/// If [path] is not a directory then a [RemoveDirException] is thrown.
///
/// If the directory does not exists a [RemoveDirException] is thrown.
///
/// If the directory cannot be delete (e.g. permissions) a [RemoveDirException] is thrown.
///
/// If recursive is false the directory must be empty otherwise a [RemoveDirException] is thrown.
void deleteDir(String path, {bool recursive}) =>
    RemoveDir().removeDir(path, recursive: recursive);

class RemoveDir extends Command {
  void removeDir(String path, {bool recursive}) {
    if (Settings().debug_on) {
      Log.d("removeDir:  ${absolute(path)} recursive: $recursive");
    }

    if (!exists(path)) {
      throw RemoveDirException("The path ${absolute(path)} does not exist.");
    }

    if (!isDirectory(path)) {
      throw RemoveDirException(
          "The path ${absolute(path)} is not a directory.");
    }

    try {
      Directory(path).deleteSync(recursive: recursive);
    } catch (e) {
      throw RemoveDirException(
          "Unable to delete the directory ${absolute(path)}. Error: $e");
    }
  }
}

class RemoveDirException extends CommandException {
  RemoveDirException(String reason) : super(reason);
}
