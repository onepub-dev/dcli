import 'dart:io';

import 'package:dshell/commands/command.dart';
import 'package:path/path.dart' as p;

import '../util/log.dart';
import 'is.dart';
import 'settings.dart';

/// Change Directories to the relative or absolute path.
///
/// If [path] does not exists an exception is thrown
///
/// ```dart
/// cd("/tmp");
/// ```
///
/// NOTE: changing the directory changes the directory
/// for all isolates.
///
/// Using push/pop/cd is considered bad form.
///
/// Instead use absolute paths.
///
/// See [push]
///     [pop]
///     [pwd]
///     [join] us join in prefrence to cd/push/pop

void cd(String path) => CD().cd(path);

class CD extends Command {
  void cd(String path) {
    if (Settings().debug_on) {
      Log.d("cd $path -> ${p.canonicalize(path)}");
    }

    if (!exists(path)) {
      throw CDException("The path ${p.canonicalize(path)} does not exists.");
    }
    Directory.current = p.join(Directory.current.path, path);
  }
}

class CDException extends CommandException {
  CDException(String reason) : super(reason);
}
