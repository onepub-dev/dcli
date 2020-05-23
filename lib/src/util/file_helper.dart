import 'dart:io';

/// Writes [content] to the file at [path].
/// The file is trunctated and then written to.
/// 
void writeToFile(String path, String content) {
  File _file;
  RandomAccessFile _raf;

  _file = File(path);

  _raf = _file.openSync(mode: FileMode.write);
  _raf.writeStringSync(content);

  _raf.closeSync();
}
