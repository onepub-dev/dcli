import 'dart:io';

import 'package:dshell/commands/command.dart';

///
/// Returns true if the given path points to a file.
bool isFile(String path) => Is().isFile(path);

/// Returns try if the given path is a directory.
bool isDirectory(String path) => Is().isDirectory(path);

// returns true if the given path exists.
// It may be a file or a directory.
bool exists(String path) => Is().exists(path);

class Is extends Command {
  bool isFile(String path) {
    FileSystemEntityType fromType = FileSystemEntity.typeSync(path);
    return (fromType == FileSystemEntityType.file);
  }

  /// true if the given path is a directory.
  bool isDirectory(String path) {
    FileSystemEntityType fromType = FileSystemEntity.typeSync(path);
    return (fromType == FileSystemEntityType.directory);
  }

  /// checks if the given [path] exists.
  bool exists(String path) {
    return File(path).existsSync();
  }
}
