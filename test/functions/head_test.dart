import 'dart:io';

import 'package:dshell/src/util/file_sync.dart';
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_fs_zone.dart';
import '../util/test_paths.dart';

void main() {
  TestPaths();

  Settings().debug_on = true;

  t.group('Head', () {
    t.test('head 5', () {
      TestZone().run(() {
        var testFile = join(TestPaths.TEST_ROOT, 'lines.txt');
        if (exists(testFile)) {
          delete(testFile);
        }
        if (!exists(TestPaths.TEST_ROOT)) {
          createDir(TestPaths.TEST_ROOT, recursive: true);
        }
        var file = FileSync(testFile, fileMode: FileMode.write);
        for (var i = 0; i < 10; i++) {
          file.append('Line ${i} is here');
        }
        file.close();

        var lines = head(testFile, 5).toList();

        t.expect(lines.length, t.equals(5));
      });
    });
  });
}
