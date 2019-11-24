import 'dart:io';

import 'log.dart';

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
  return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
}

DateTime lastModified(String path) {
  return File(path).lastModifiedSync();
}

void setLastModifed(String path, DateTime lastModified) {
  File(path).setLastModifiedSync(lastModified);
}

void writeToFile(String path, String content) {
  File _file;
  RandomAccessFile _raf;

  _file = File(path);

  _raf = _file.openSync(mode: FileMode.write);
  _raf.writeStringSync(content);

  _raf.closeSync();
}

/// Returns true if the directory already
/// existed.
bool createDir(String dir, String description) {
  bool created = false;
  Directory directory = Directory(dir);
  if (!directory.existsSync()) {
    try {
      directory.createSync(recursive: true);
      created = true;
    } catch (e) {
      Log().error(
          "Unable to create the $description ${dir}. Error: ${e.toString()}");
      rethrow;
    }
  }
  return !created;
}
