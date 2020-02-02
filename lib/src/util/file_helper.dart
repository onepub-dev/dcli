import 'dart:io';

import '../../dshell.dart';
import 'log.dart';

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
  var created = false;
  var directory = Directory(dir);
  if (!directory.existsSync()) {
    try {
      directory.createSync(recursive: true);
      created = true;
    } catch (e) {
      printerr(
          'Unable to create the $description ${dir}. Error: ${e.toString()}');
      rethrow;
    }
  }
  return !created;
}
