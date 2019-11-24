import 'dart:io';

import '../util/log.dart';

import 'dshell_function.dart';
import 'is.dart';
import 'ask.dart';
import 'settings.dart';

///
/// Deletes the file at [path].
///
/// If the file does not exists a DeleteException is thrown.
///
/// ```dart
/// delete("/tmp/test.fred", ask = true);
/// ```
///
/// If [ask] is true then the user is prompted to confirm the file deletion.
/// The default value for [ask] is false.
///
/// If the [path] is a directory a DeleteException is thrown.
void delete(String path, {bool ask = false}) => Delete().delete(path, ask: ask);

class Delete extends DShellFunction {
  void delete(String path, {bool ask}) {
    if (Settings().debug_on) {
      Log.d("delete:  ${absolute(path)} ask: $ask");
    }

    if (!exists(path)) {
      throw DeleteException("The path ${absolute(path)} does not exists.");
    }

    if (isDirectory(path)) {
      throw DeleteException("The path ${absolute(path)} is a directory.");
    }

    bool remove = true;
    if (ask) {
      remove = false;
      String yes = Ask().ask(
          prompt: "delete: Delete the regular file '${absolute(path)}'? y/N");
      if (yes == "y") {
        remove = true;
      }
    }

    if (remove == true) {
      try {
        File(path).deleteSync();
      } catch (e) {
        throw DeleteException(
            "An error occured deleting ${absolute(path)}. Error: $e");
      }
    }
  }
}

class DeleteException extends DShellFunctionException {
  DeleteException(String reason) : super(reason);
}
