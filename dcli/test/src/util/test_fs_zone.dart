@Timeout(Duration(seconds: 600))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';
import 'package:file/memory.dart';
import 'package:test/test.dart';

class TestZone {
  TestZone({
    FileSystemStyle style = FileSystemStyle.posix,
    MemoryFileSystem? fileSystem,
  }) {
    if (fileSystem == null) {
      _fs = MemoryFileSystem(style: style);
    } else {
      _fs = fileSystem;
    }
  }

  late MemoryFileSystem _fs;

  void run<R>(R Function() body) {
    IOOverrides.runZoned(
      body,
      // createDirectory: (String path) => _fs.directory(path),
      // createFile: (String path) => _fs.file(path),
      // createLink: (String path) => _fs.link(path),
      // getCurrentDirectory: () => _fs.currentDirectory,
      // setCurrentDirectory: (String path) => _fs.currentDirectory = path,
      // getSystemTempDirectory: () => _fs.systemTempDirectory,
      // stat: (String path) => _fs.stat(path),
      // statSync: (String path) => _fs.statSync(path),
      // fseIdentical: (String p1, String p2) => _fs.identical(p1, p2),
      // fseIdenticalSync: (String p1, String p2) => _fs.identicalSync(p1, p2),
      // fseGetType: (String path, bool followLinks) =>
      //     _fs.type(path, followLinks: followLinks),
      // fseGetTypeSync: (String path, bool followLinks) =>
      //     typeSync(path, followLinks),
      // fsWatch: (String a, int b, bool c) =>
      //     throw UnsupportedError('unsupported'),
      // fsWatchIsSupported: () => _fs.isWatchSupported
    );
  }

  FileSystemEntityType typeSync(String path, {required bool followLinks}) {
    var _path = path;
    _path = _path.substring(0, _path.length - 1);

    return _fs.typeSync(_path, followLinks: followLinks);
  }
}
