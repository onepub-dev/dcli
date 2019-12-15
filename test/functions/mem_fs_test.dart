import 'dart:io';

import 'package:file/memory.dart';
import 'package:test/test.dart' as t;

import '../util/test_fs_zone.dart';

void main() {
  t.test("MemoryFile CWD", () {
    MemoryFileSystem fs = MemoryFileSystem();
    print("No style: ${fs.currentDirectory}");

    final FileSystemStyle style = FileSystemStyle.posix;
    fs = MemoryFileSystem(style: style);
    print("Posix style: ${fs.currentDirectory}");
  });

  t.test("Zone CWS", () {
 

    TestZone(style: FileSystemStyle.posix).run(() {
      print("No style: ${Directory.current}");
    });
  });
}
