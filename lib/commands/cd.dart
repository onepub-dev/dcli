import 'dart:io';

import 'package:dshell/commands/command.dart';

import '../util/log.dart';
import 'is.dart';
import 'settings.dart';

/// Change Directories to the relative or absolute path.
///
/// If [path] does not exists an exception is thrown
///
/// Note: changing the directory changes the directory
/// for all isolates.
///
/// See [push]
///     [pop]
///     [pwd]

void cd(String path) => CD().cd(path);

class CD extends Command {
  void cd(String path) {
    if (Settings().debug_on) {
      Log.d("cd $path -> ${absolute(path)}");
    }

    if (!exists(path)) {
      throw CDException("The path ${absolute(path)} does not exists.");
    }
    Directory.current = path;
  }
}

class CDException extends CommandException {
  CDException(String reason) : super(reason);
}
