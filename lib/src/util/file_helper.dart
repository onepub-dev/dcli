import 'dart:io';

void writeToFile(String path, String content) {
  File _file;
  RandomAccessFile _raf;

  _file = File(path);

  _raf = _file.openSync(mode: FileMode.write);
  _raf.writeStringSync(content);

  _raf.closeSync();
}
