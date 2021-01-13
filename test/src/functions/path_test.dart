@t.Timeout(Duration(seconds: 600))
import 'dart:io';

import 'package:dcli/src/functions/env.dart';
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';

import '../util/test_file_system.dart';

String _testDir = 'path_test';
void main() {
  t.group('Directory Path manipulation testing', () {
    t.test('PWD', () {
      TestFileSystem().withinZone((fs) {
        t.expect(pwd, t.equals(Directory.current.path));
      });
    });
  });
}

class Paths {
  String home;
  String pathTestDir;
  String testExtension;
  String testBaseName;
  String testFile;

  Paths(TestFileSystem fs) {
    home = HOME;
    pathTestDir = join(fs.fsRoot, _testDir, 'pathTestDir');
    testExtension = '.jpg';
    testBaseName = 'fred';
    testFile = '$testBaseName$testExtension';
  }
}

Paths setup(TestFileSystem fs) {
  return Paths(fs);
}
