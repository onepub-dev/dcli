import 'dart:io';

/// Writes [content] to the file at [path].
/// The file is trunctated and then written to.
///
void writeToFile(String path, String content) {
  File _file;

  _file = File(path);

  _file.openSync(mode: FileMode.write)
    ..writeStringSync(content)
    ..closeSync();
}
