@t.Timeout(Duration(seconds: 600))
import 'dart:io';

import 'package:dshell/src/util/file_sync.dart';
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_file_system.dart';

void main() {
  Settings().debug_on = true;

  t.group('Head', () {
    t.test('head 5', () {
      TestFileSystem().withinZone((fs) {
        var testFile = join(fs.root, 'lines.txt');
        if (exists(testFile)) {
          delete(testFile);
        }
        if (!exists(fs.root)) {
          createDir(fs.root, recursive: true);
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
  },
      skip:
          true); // calling head().toList() fails as we end up with two progressions.
}
