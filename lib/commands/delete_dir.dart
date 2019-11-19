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
/// ```dart
/// deleteDir("/tmp/testing", recursive=true);
/// ```
///
/// If [path] is not a directory then a [DeleteDirException] is thrown.
///
/// If the directory does not exists a [DeleteDirException] is thrown.
///
/// If the directory cannot be delete (e.g. permissions) a [DeleteDirException] is thrown.
///
/// If recursive is false the directory must be empty otherwise a [DeleteDirException] is thrown.
void deleteDir(String path, {bool recursive}) =>
    DeleteDir().deleteDir(path, recursive: recursive);

class DeleteDir extends Command {
  void deleteDir(String path, {bool recursive}) {
    if (Settings().debug_on) {
      Log.d("deleteDir:  ${absolute(path)} recursive: $recursive");
    }

    if (!exists(path)) {
      throw DeleteDirException("The path ${absolute(path)} does not exist.");
    }

    if (!isDirectory(path)) {
      throw DeleteDirException(
          "The path ${absolute(path)} is not a directory.");
    }

    try {
      Directory(path).deleteSync(recursive: recursive);
    } catch (e) {
      throw DeleteDirException(
          "Unable to delete the directory ${absolute(path)}. Error: $e");
    }
  }
}

class DeleteDirException extends CommandException {
  DeleteDirException(String reason) : super(reason);
}
