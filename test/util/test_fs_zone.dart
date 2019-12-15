import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file/memory.dart';

class TestZone {
  MemoryFileSystem _fs;

  TestZone({
    FileSystemStyle style = FileSystemStyle.posix,
    MemoryFileSystem fileSystem,
  }) {
    if (fileSystem == null) {
      _fs = MemoryFileSystem(style: style);
    } else {
      _fs = fileSystem;
    }
  }

  void run<R>(R body()) {
    IOOverrides.runZoned(body,
        createDirectory: (String path) => _fs.directory(path),
        createFile: (String path) => _fs.file(path),
        createLink: (String path) => _fs.link(path),
        getCurrentDirectory: () => _fs.currentDirectory,
        setCurrentDirectory: (String path) => _fs.currentDirectory = path,
        getSystemTempDirectory: () => _fs.systemTempDirectory,
        stat: (String path) => _fs.stat(path),
        statSync: (String path) => _fs.statSync(path),
        fseIdentical: (String p1, String p2) => _fs.identical(p1, p2),
        fseIdenticalSync: (String p1, String p2) => _fs.identicalSync(p1, p2),
        fseGetType: (String path, bool followLinks) =>
            _fs.type(path, followLinks: followLinks),
        fseGetTypeSync: (String path, bool followLinks) =>
            typeSync(path, followLinks),
        fsWatch: (String a, int b, bool c) =>
            throw UnsupportedError('unsupported'),
        fsWatchIsSupported: () => _fs.isWatchSupported);
  }

  FileSystemEntityType typeSync(String path, bool followLinks) {
    path = path.substring(0, path.length - 1);

    return _fs.typeSync(path, followLinks: followLinks);
  }

  static String _toStringFromUtf8Array(Uint8List l) {
    if (l == null) {
      return '';
    }
    Uint8List nonNullTerminated = l;
    if (l.last == 0) {
      nonNullTerminated = new Uint8List.view(l.buffer, 0, l.length - 1);
    }
    return utf8.decode(nonNullTerminated, allowMalformed: true);
  }
}
