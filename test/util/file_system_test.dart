import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:test/test.dart';

import 'test_fs_zone.dart';
import 'test_paths.dart';

void main() {
  TestPaths();
  
  test('MemoryFileSystem', () {
    TestZone().run(() {
      // final fs = MemoryFileSystem();

      // fs.directory('/tmp').createSync();
      // assert(fs.statSync('/tmp').type != FileSystemEntityType.notFound);

      // fs.file('.');

      var restoreTo = Directory.current;

      print('root cwd: ${Directory.current}');

      print('testzone cwd: ${Directory.current}');

      Directory.current = '/';
      var dir = '/tmp/mfs.test';
      // Directory(dir).createSync();
      if (!exists(dir)) {
        createDir(dir);
      }
      print('testzone post cwd: ${pwd}');

      Directory.current = restoreTo;
    });
  }, skip: true);
}
